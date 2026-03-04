import pandas as pd
from prophet import Prophet
import sys
import json
import warnings
from datetime import datetime
warnings.filterwarnings('ignore')

def predict_rainfall(csv_path, target_month_str=None):
    try:
        # =========================
        # 1. ĐỌC CSV
        # =========================
        df = pd.read_csv(csv_path)

        df = df[['date', 'prcp']].copy()
        df.rename(columns={'date': 'ds', 'prcp': 'y'}, inplace=True)

        df['ds'] = pd.to_datetime(df['ds'])
        df = df.dropna(subset=['y'])

        # =========================
        # 2. GOM THÁNG + LỌC
        # =========================
        df_monthly = (
            df
            .set_index('ds')
            .resample('ME')
            .agg(
                y=('y', 'sum'),
                valid_days=('y', 'count')
            )
            .reset_index()
        )

        df_monthly = df_monthly[df_monthly['valid_days'] >= 20]

        if len(df_monthly) < 2:
            return {"status": "error", "message": "Not enough data to train"}

        # =========================
        # 3. KIỂM TRA THÁNG QUÁ KHỨ hay TƯƠNG LAI
        # =========================
        target_date = None
        is_historical = False

        if target_month_str:
            try:
                target_date = pd.to_datetime(target_month_str + '-01')
                last_date = df_monthly['ds'].max()
                # If target month is within historical data range, use actual data
                if target_date <= last_date:
                    is_historical = True
            except Exception:
                pass

        # =========================
        # 4. XỬ LÝ THÁNG QUÁ KHỨ — dùng dữ liệu thực tế
        # =========================
        if is_historical and target_date is not None:
            target_month_str_fmt = target_date.strftime('%Y-%m')
            # Find exact match in historical data
            match = df_monthly[df_monthly['ds'].dt.strftime('%Y-%m') == target_month_str_fmt]
            if not match.empty:
                rain = float(match.iloc[0]['y'])
                if rain < 0:
                    rain = 0
                rain = round(rain, 1)
            else:
                # Target month exists in past but missing data — use Prophet trained on all data up to target month
                df_train = df_monthly[df_monthly['ds'] <= target_date]
                if len(df_train) < 2:
                    return {"status": "error", "message": "Not enough historical data for that month"}
                model = Prophet(yearly_seasonality=True, weekly_seasonality=False, daily_seasonality=False)
                model.fit(df_train)
                future = pd.DataFrame({'ds': [target_date]})
                fc = model.predict(future)
                rain = max(0.0, round(float(fc.iloc[0]['yhat']), 1))

            if rain > 200:
                risk = "Nguy cơ ngập"
            elif rain > 120:
                risk = "Mưa lớn"
            else:
                risk = "Bình thường"

            return {
                "status": "success",
                "data_source": "historical",
                "forecasts": [{
                    "month": target_month_str_fmt,
                    "predicted_rain_mm": rain,
                    "risk_level": risk
                }]
            }

        # =========================
        # 5. HUẤN LUYỆN PROPHET (cho tương lai hoặc tháng thiếu data)
        # =========================
        model = Prophet(
            yearly_seasonality=True,
            weekly_seasonality=False,
            daily_seasonality=False
        )
        model.fit(df_monthly)

        # =========================
        # 6. TÍNH SỐ THÁNG CẦN DỰ BÁO
        # =========================
        periods = 12
        last_date = df_monthly['ds'].max()

        if target_date is not None:
            diff_months = (target_date.year - last_date.year) * 12 + (target_date.month - last_date.month)
            if diff_months > 0:
                periods = diff_months + 1
            if periods > 120:
                periods = 120  # Cap at 10 years

        # =========================
        # 7. DỰ BÁO
        # =========================
        future = model.make_future_dataframe(periods=periods, freq='ME')
        forecast = model.predict(future)

        # =========================
        # 8. KẾT QUẢ
        # =========================
        forecast_list = []
        result_all = forecast[['ds', 'yhat']]

        for _, row in result_all.iterrows():
            month = row['ds'].strftime('%Y-%m')

            # If target_month_str is provided, we only want that specific month
            if target_month_str and month != target_month_str:
                continue

            rain = float(row['yhat'])
            if rain < 0:
                rain = 0

            if rain > 200:
                risk = "Nguy cơ ngập"
            elif rain > 120:
                risk = "Mưa lớn"
            else:
                risk = "Bình thường"

            forecast_list.append({
                "month": month,
                "predicted_rain_mm": round(rain, 1),
                "risk_level": risk
            })

            if target_month_str:
                break  # Found it

        # If no specific month was asked, just return the future months
        if not target_month_str and len(forecast_list) > len(df_monthly):
            forecast_list = forecast_list[-periods:]

        return {"status": "success", "data_source": "forecast", "forecasts": forecast_list}

    except Exception as e:
        return {"status": "error", "message": str(e)}

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(json.dumps({"status": "error", "message": "Missing CSV file path"}))
        sys.exit(1)

    file_path = sys.argv[1]
    target_month = sys.argv[2] if len(sys.argv) > 2 else None

    output = predict_rainfall(file_path, target_month)
    print(json.dumps(output, ensure_ascii=False))
