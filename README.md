Form Generator
Generates HTML forms from JSON schema definitions.

1. Quick Start
   Install dependencies:
   mix deps.get

2. Compile the project:
   mix compile

3. Create a JSON file or use the existing one (form_schema.json):
   {  
    "phone": { "type": "tel", "label": "Phone number" },
   "email": { "type": "email", "label": "Email Address" }
   }

4. Use the provided script (test_generator.exs):

   # This file reads form_schema.json and generates HTML

5. Run the script:
   mix run test_generator.exs > output.html

6. View the output:
   Open output.html in a browser to see the generated form.
