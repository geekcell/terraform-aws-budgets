variables {
  name       = "test-budget"
  recipients = ["tommy.tester@test.com"]

  budgets = [{
    name = "test-budget-1",

    budget_type  = "COST"
    limit_amount = 50
    limit_unit   = "EUR"

    time_period_start = "2023-01-01_00:00"
    time_period_end   = "2087-06-15_00:00"
    time_unit         = "MONTHLY"

    notification = {
      comparison_operator = "GREATER_THAN"
      threshold           = "69"
      threshold_type      = "PERCENTAGE"
      notification_type   = "FORECASTED"
    }
  }]
}

run "basic_budget" {
  command = plan

  assert {
    condition     = length(aws_budgets_budget.main) == 1
    error_message = "Expected one budget to be created."
  }

  assert {
    condition     = contains(keys(aws_budgets_budget.main), "test-budget-1")
    error_message = "Expected test-budget-1 to exist."
  }

  assert {
    condition     = length(aws_budgets_budget.main["test-budget-1"].notification) == 1
    error_message = "Expected test-budget-1 to have one notification."
  }

  assert {
    condition = alltrue([
      for n in aws_budgets_budget.main["test-budget-1"].notification : can(length(n.subscriber_email_addresses) == 1)
    ])

    error_message = "Expected test-budget-1 notification to have one recipient."
  }

  assert {
    condition     = aws_budgets_budget.main["test-budget-1"].limit_amount == "50"
    error_message = "Expected test-budget-1 limit amount to be 50."
  }

  assert {
    condition     = aws_budgets_budget.main["test-budget-1"].limit_unit == "EUR"
    error_message = "Expected test-budget-1 limit unit to be EUR."
  }

  assert {
    condition = alltrue([
      for n in aws_budgets_budget.main["test-budget-1"].notification : can(n.threshold == 69)
    ])

    error_message = "Expected test-budget-1 threshold to be 69%."
  }
}
