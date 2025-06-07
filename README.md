# Shipping Calculator

This Ruby-based tool calculates and returns the best shipping route based on sailing, rate, and currency exchange data from a JSON file (`response.json`).
The application is packaged in a lightweight Docker image for easy development and execution.

---

## 🐳 Docker Setup

You can either run commands directly using `docker compose` or use the provided `Makefile` for convenience.

```bash
make build        # Builds the Docker image
make bash         # Opens a shell inside the app container
make specs        # Runs the RSpec test suite
```

### 🔧 Using docker compose directly

```bash
docker compose build
docker compose run --rm app bash
docker compose run --rm app bundle exec rspec
```

This will install Ruby 3.4, dependencies, and bundle your gems.

---

## 🚀 How to Run

### Option 1: Run with arguments

You can pass the origin, destination, and search criteria as arguments:

```bash
docker compose run --rm app ruby bin/run CNSHA NLRTM cheapest-direct
```

### Option 2: Run interactively

If you don’t pass arguments, the program will prompt you for them:

```bash
docker compose run --rm app ruby bin/run
```

---

## 🧪 Running the test suite

Run RSpec inside the container:


```bash
make specs
# or
docker compose run --rm app bundle exec rspec
```

This will execute all tests defined in `spec/`.

---

## 📁 Project Structure

```
bin/
  run                    # CLI entry point
lib/
  shipping_calculator/
    models/              # Domain models (e.g., Sailing)
    services/            # Application services (e.g., RouteFinder)
    rate_converter.rb    # Currency conversion logic
    service.rb           # Main orchestrator
spec/
  shipping_calculator/   # RSpec tests
response.json            # Sample data input
```

---

## 💡 Notes

- Gems are cached in a Docker volume (`bundle_data`) to speed up rebuilds.
- You don’t need to install Ruby or Bundler locally.
- You can use `docker compose run --rm app bash` to open a development shell inside the container.

---

## ✨ Example

```bash
docker compose run --rm app ruby bin/run CNSHA NLRTM cheapest-direct
```

Returns:

```json
[
  {
    "origin_port": "CNSHA",
    "destination_port": "NLRTM",
    "departure_date": "2022-01-30",
    "arrival_date": "2022-03-05",
    "sailing_code": "MNOP",
    "rate": "456.78",
    "rate_currency": "USD"
  }
]
```
