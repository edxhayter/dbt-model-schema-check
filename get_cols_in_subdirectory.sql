{% macro name(directory) %}

  {% set models_in_subdirectory = [] -%}
  
  {% for node in graph.nodes.values() -%}
      {% if node.resource_type == 'model' and directory in node.original_file_path -%}
          {% do models_in_subdirectory.append(node.name) -%}
      {% endif -%}
  {% endfor -%}
  
  {# -- uncomment out this Jinja to regenerate the list to add to the top of the model to fix dependencies
  {% for model in models_in_subdirectory %}
    -- depends_on: {{ "{{ ref('" + model + "') }}" }}
  {% endfor %}
  #}
  
  -- Build SQL to unpivot and union all
  {%- for model in models_in_subdirectory %}
    {%- set columns = dbt.get_columns_in_relation(ref(model)) -%}
      {%- set column_names = [] -%}
      {%- for column in columns %}
        {%- set column_str = column | string -%}
        {%- set column_name = column_str.split(' ')[1] -%}
        {%- do column_names.append(column_name) -%}
      {%- endfor %}
  
    SELECT 
      '{{ model }}' AS model,
      '{{ column_names | join(',') }}' as column_names
    {%- if not loop.last %} 
      UNION ALL
    {%- endif %}
  {%- endfor %}

{% endmacro %}
