# Kelly's Notes:
# There is a ton of repetition in this code.
# That is bad.
# Refactoring with different methods and/or looping is needed.
# For now I'm happy that it works!

require "pg"
require "csv"

def db_connection
  begin
    connection = PG.connect(dbname: "korning")
    yield(connection)
  rescue PG::UniqueViolation
    puts "ERROR: Data already exists in table."
  ensure
    connection.close
  end
end

def csv_conversion
  sales_array = CSV.read("sales.csv", headers: true)
  sales_array
end

def employee_array
  employees = []
  csv_conversion.each do |item|
    employees << item[0] unless employees.include? item[0]
  end

  emp_ary = []
  employees.each do |entry|
    emp_ary << entry.split
  end

  emp_ary.each do |array|
    array[2].delete!('()')
  end

  emp_ary
end

def accounts_array
  accounts = []
  csv_conversion.each do |item|
      accounts << item[1] unless accounts.include? item[1]
  end

  acc_ary = []
  accounts.each do |entry|
    acc_ary << entry.split
  end

  acc_ary.each do |array|
    array[1].delete!('()')
  end

  acc_ary
end

def product_array
  products = []
  csv_conversion.each do |item|
    products << item[2] unless products.include? item[2]
  end

  products
end

# This def is very ugly. Needs serious refactoring. At least it works!
def transactions_array
  basic_data = csv_conversion.to_a

  # Hashes for all info I'm going to swap
  employee_hash = db_connection do |conn|
    conn.exec("SELECT (id, email) FROM employees")
  end
  customer_hash = db_connection do |conn|
    conn.exec("SELECT (account_id, company) FROM customers")
  end
  product_hash = db_connection do |conn|
    conn.exec("SELECT (id, name) FROM products")
  end
  frequency_hash = db_connection do |conn|
    conn.exec("SELECT (id, name) FROM frequency")
  end

  # For some reason header still appearing, thus .shift
  basic_data.shift

  basic_data.each do |info|

    # Swaps employee with id where email matches
    employee_hash.to_a.each do |hash|
      temp_ary = hash["row"].delete("()").split(",")
      if info[0].include? temp_ary[1]
          info[0] = temp_ary[0]
      end
    end

    # Swaps customer_and_account_no with id where account_id matches
    customer_hash.to_a.each do |hash|
      temp_ary = hash["row"].delete("()").split(",")
      if info[1].include? temp_ary[1]
        info[1] = temp_ary[0]
      end
    end

    # Swaps product_name with id
    product_hash.to_a.each do |hash|
      temp_ary = hash["row"].delete("()\"").split(",")
      if info[2].include? temp_ary[1]
        info[2] = temp_ary[0]
      end
    end

    # Swaps invoice_frequency with id
    frequency_hash.to_a.each do |hash|
      temp_ary = hash["row"].delete("()").split(",")
      if info[7].downcase.include? temp_ary[1]
        info[7] = temp_ary[0]
      end
    end
  end

  basic_data
end

# Populate Employees Table
employee_array.each do |array|
  db_connection do |conn|
    conn.exec_params(
    "INSERT INTO employees (first_name, last_name, email)
    VALUES ($1, $2, $3)", [array[0], array[1], array[2]])
  end
end

# Populate Customers Table
accounts_array.each do |array|
  db_connection do |conn|
    conn.exec_params(
    "INSERT INTO customers (account_id, company)
    VALUES ($1, $2)", [array[1], array[0]])
  end
end

# Populate Products Table
product_array.each do |product|
  db_connection do |conn|
    conn.exec_params(
    "INSERT INTO products (name)
    VALUES ($1)", [product])
  end
end

# Populate Transactions Table
transactions_array.each do |trans|
  db_connection do |conn|
    conn.exec_params(
    "INSERT INTO transactions (
    employee,
    customer,
    product,
    sale_date,
    sale_amount,
    units_sold,
    invoice_id,
    frequency
    )
    VALUES ($1, $2, $3, $4, $5, $6, $7, $8)",
    [trans[0], trans[1], trans[2], trans[3],
    trans[4], trans[5], trans[6], trans[7]]
    )
  end
end
