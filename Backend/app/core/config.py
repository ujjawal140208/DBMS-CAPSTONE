from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    app_name: str = "Hospital Patient & Appointment Management System"
    api_prefix: str = "/api"
    database_url: str = "mysql+pymysql://hospital_user:change_me@localhost:3306/hospital_db"
    frontend_origin: str = "http://localhost:5173"
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

settings = Settings()
