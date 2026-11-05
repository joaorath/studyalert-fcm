"""Aplica as configuracoes Android/Firebase no projeto gerado pelo Flutter."""
from pathlib import Path

settings = Path('android/settings.gradle.kts')
app_gradle = Path('android/app/build.gradle.kts')
manifest = Path('android/app/src/main/AndroidManifest.xml')

if not (settings.exists() and app_gradle.exists() and manifest.exists()):
    raise SystemExit('Projeto Android em Kotlin DSL não foi gerado pelo flutter create.')

s = settings.read_text()
line = '    id("com.google.gms.google-services") version "4.5.0" apply false\n'
if 'com.google.gms.google-services' not in s:
    anchor = '    id("dev.flutter.flutter-plugin-loader") version "1.0.0"\n'
    if anchor not in s:
        raise SystemExit('Nao encontrei o ponto de insercao no settings.gradle.kts')
    s = s.replace(anchor, anchor + line)
    settings.write_text(s)

s = app_gradle.read_text()
line = '    id("com.google.gms.google-services")\n'
if 'com.google.gms.google-services' not in s:
    anchor = '    id("com.android.application")\n'
    if anchor not in s:
        raise SystemExit('Nao encontrei o plugin Android no build.gradle.kts')
    s = s.replace(anchor, anchor + line)
    app_gradle.write_text(s)

s = manifest.read_text()
for permission in ('android.permission.INTERNET', 'android.permission.POST_NOTIFICATIONS'):
    if permission not in s:
        anchor = '<manifest xmlns:android="http://schemas.android.com/apk/res/android">'
        if anchor not in s:
            raise SystemExit('Nao encontrei a abertura do AndroidManifest.xml')
        s = s.replace(anchor, anchor + f'\n    <uses-permission android:name="{permission}" />')
s = s.replace('android:label="studyalert"', 'android:label="StudyAlert"')
manifest.write_text(s)
print('Android configurado para Firebase + permissoes.')
