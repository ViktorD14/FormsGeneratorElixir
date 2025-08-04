# test_generator.exs

# Sample JSON
json_string = File.read!("form_schema.json")

# Run the generator
{:ok, html} = FormGenerator.HTMLFormsGenerator.generate_from_json(json_string)
IO.puts(html)
