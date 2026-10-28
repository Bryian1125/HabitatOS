with open('lib/screens/resources_screen.dart') as f:
    text = f.read()
old = "                                         final spacing = resource.history.length > 1 ? resource.lastEditTime.difference(DateTime(resource.lastEditTime.year, resource.lastEditTime.month, resource.lastEditTime.day)).inMinutes / (resource.history.length - 1) : 0;"
new = "                                         final lt = resource.lastEditTime!;\n                                         final spacing = resource.history.length > 1 ? lt.difference(DateTime(lt.year, lt.month, lt.day)).inMinutes / (resource.history.length - 1) : 0;"
text = text.replace(old, new)
with open('lib/screens/resources_screen.dart', 'w') as f:
    f.write(text)
print('fixed')
