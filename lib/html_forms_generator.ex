defmodule FormGenerator.HTMLFormsGenerator do

  #Generates HTML form markup from JSON schema definitions.
  #Returns the generated HTML as text without file operations.


  # Keys we don't want to include in the generic attribute handling
  @skip_keys ["id", "name", "type", "label", "hint", "options", "placeholder", "schema"]


  #Main entry point - takes a JSON string and returns generated HTML form content

  def generate_from_json(json_string) do
    case Jason.decode(json_string) do
      {:ok, schema} ->
        {:ok, render_form(schema)}
      {:error, reason} ->
        {:error, "Failed to parse JSON: #{inspect(reason)}"}
    end
  end


  #Alternative entry point - takes an already decoded schema map

  def generate_from_schema(schema) when is_map(schema) do
    {:ok, render_form(schema)}
  end


  #Renders a complete form from the schema

  def render_form(schema) do
    render_fields(schema)
  end


  #Renders all fields in the schema

  def render_fields(field_defs, parent_name \\ "") do
    field_defs
    |> Enum.map(fn {field_name, field} ->
      # Generate name and id attributes
      name_attr = if parent_name != "",
                  do: "#{parent_name}[#{field_name}]",
                  else: field_name
      id_attr = name_attr

      # Label text and optional hint
      label_text = Map.get(field, "label", String.capitalize(field_name))
      hint_html = if Map.has_key?(field, "hint"),
                  do: "<div class=\"hint\">#{field["hint"]}</div>",
                  else: ""

      # Render the appropriate field type
      inner_html = render_field_by_type(field, field_name, name_attr, id_attr)

      """
        <div>
          <label for="#{id_attr}">#{label_text}</label>
          #{inner_html}
          #{hint_html}
        </div>
      """
    end)
    |> Enum.join("")
  end


  #Renders a field based on its type

  def render_field_by_type(%{"type" => "schema", "schema" => schema}, field_name, name_attr, _id_attr) do
   label_text = Map.get(schema, "label", String.capitalize(field_name))
    """
      <fieldset>
        <legend>#{label_text}</legend>
        #{render_fields(schema, name_attr)}
      </fieldset>
    """
  end

  def render_field_by_type(%{"type" => "select"} = field, _field_name, name_attr, id_attr) do
    # Handle placeholder option
    placeholder_opt = if Map.has_key?(field, "placeholder"),
                      do: "<option value=\"\" disabled selected hidden>#{field["placeholder"]}</option>",
                      else: ""

    # Generate options
    options_html = case Map.get(field, "options", []) do
      options when is_list(options) ->
        options
        |> Enum.filter(fn [value, _label] -> value != "" end)
        |> Enum.map(fn [value, label] -> "<option value=\"#{value}\">#{label}</option>" end)
        |> Enum.join("")
      _ -> ""
    end

    """
      <select name="#{name_attr}" id="#{id_attr}" #{build_attr_string(field)}>
        #{placeholder_opt}
        #{options_html}
      </select>
    """
  end

  def render_field_by_type(%{"type" => "textarea"} = field, _field_name, name_attr, id_attr) do
    value = Map.get(field, "defaultValue", "")
    """
      <textarea name="#{name_attr}" id="#{id_attr}" #{build_attr_string(field)}>#{value}</textarea>
    """
  end

  def render_field_by_type(field, _field_name, name_attr, id_attr) do
    """
      <input type="#{field["type"]}" name="#{name_attr}" id="#{id_attr}" #{build_attr_string(field)}>
    """
  end


  #Builds HTML attribute string from field properties

  def build_attr_string(field) do
    field
    |> Enum.filter(fn {key, val} ->
      key not in @skip_keys && val != nil && val != ""
    end)
    |> Enum.map(fn {key, val} -> "#{key}=\"#{val}\"" end)
    |> Enum.join(" ")
  end
end
