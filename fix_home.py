with open('lib/screens/home_screen.dart') as f:
    content = f.read()
start = content.find('_DataPanel(')
end_marker = '        ),'
end = content.find(end_marker, start)
new_text = content[:start] + "_DataPanel(\n          title: 'Most updated resource',\n          subtitle: 'visualization based on activity',\n          child: _ResourceCard(\n            resource: Resource.create(id: 'dummy', name: 'Food', unit: 'kg', initialQuantity: 100),\n            onEdit: () {},\n          ),\n        )," + content[end+len(end_marker):]
with open('lib/screens/home_screen.dart', 'w') as f:
    f.write(new_text)
print('replaced')
