
enum Env {
  develop,
  production,
  release,
  widgetDev,
  unitTest,
  widgetTest,
  integrationTest
}

class _AppEnv {
  Env _env = Env.develop;
  Env get env => _env;
  setEnv(Env env) {
    _env = env;
  }
}

final appEnv = _AppEnv();
