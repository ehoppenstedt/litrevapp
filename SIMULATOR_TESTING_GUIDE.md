# 📱 Guía de Pruebas en el Simulador

## ¿Cómo probar la funcionalidad de highlight en el simulador?

### ⚠️ Importante: Limitaciones del Simulador

El simulador de iPad **NO soporta Apple Pencil**, pero hemos implementado el highlight de dos formas:

1. **Selección de texto tradicional** ✅ Funciona en simulador
2. **Dibujo con Apple Pencil** ⏸️ Solo funciona en iPad real

---

## 🧪 Pasos para Probar en el Simulador

### 1. Abrir el Proyecto
```bash
./open-xcode.sh
```

### 2. Seleccionar Simulador de iPad
- En la barra superior de Xcode, clic en el selector de dispositivo
- Elegir: **iPad Pro (12.9-inch) (6th generation)**
- Presionar `Cmd + R` para ejecutar

### 3. Crear un Proyecto
- Click en "+ New Project"
- Nombre: "Test Project"
- Research Question: "Does highlighting work?"
- Click "Create"

### 4. Importar un Documento

**Opción A: Desde URL (Recomendado para testing rápido)**
1. Click "+ Add Source"
2. Click "Import from URL"
3. Ingresa: `https://web.mit.edu/5.95/www/readings/bloom-two-sigma.pdf`
4. Click "Import"
5. El PDF se abrirá automáticamente en el reader

**Opción B: Usar el documento de muestra**
1. Al crear el proyecto, ya debería haber una fuente de muestra
2. Ve a "List of Sources"
3. Click en "The 2 Sigma Problem..." para abrirlo

### 5. Activar Modo Highlight

1. En el PDF Reader, click en el botón **"Enable Highlight"**
2. El botón cambiará a **"Highlighting Active"** con fondo amarillo
3. Verás un mensaje de instrucciones: **"Tap and hold to select text"**

### 6. Hacer un Highlight (en el Simulador)

**Método: Selección de Texto**
1. **Mantén presionado** (click largo) sobre un texto en el PDF
2. Aparecerán los "handles" azules de selección
3. **Arrastra** los handles para seleccionar el texto que quieres
4. **Suelta** - el texto se destacará automáticamente
5. Verás:
   - ✅ Highlight amarillo en el PDF
   - ✅ Toast verde: "✓ Saved to Notes & Quotes"
   - ✅ Mensaje en consola: "✅ Highlight saved..."

### 7. Verificar que se Guardó

1. Click en **"Back"** para volver al proyecto
2. Ve a la pestaña **"Notes & Excerpts"**
3. Deberías ver:
   - Tu research question al inicio
   - El texto que resaltaste
   - Número de página entre paréntesis

---

## 🎯 Flujo de Testing Completo

```
1. Abrir app en simulador ✓
   ↓
2. Crear proyecto ✓
   ↓
3. Importar PDF desde URL ✓
   ↓
4. PDF abre automáticamente ✓
   ↓
5. Click "Enable Highlight" ✓
   ↓
6. Ver instrucciones ✓
   ↓
7. Tap and hold en texto → seleccionar ✓
   ↓
8. Ver highlight amarillo + toast ✓
   ↓
9. Volver al proyecto ✓
   ↓
10. Ver texto en "Notes & Excerpts" ✓
```

---

## 🔍 Qué Buscar en la Consola

Cuando el highlight funcione correctamente, verás estos mensajes:

```
✏️ Highlight mode ENABLED:
   📱 In Simulator: Use tap-and-hold to select text
   🖊️ On Real iPad: Use Apple Pencil to draw highlights

✅ Highlight saved: [primeras 50 letras del texto]...
```

Si algo falla:
```
❌ Error saving highlight: [descripción del error]
```

---

## 🖊️ Probando con Apple Pencil (iPad Real)

### Requisitos
- iPad compatible con Apple Pencil
- Apple Pencil cargado y pareado
- Cable USB-C para conectar al Mac

### Pasos
1. Conecta tu iPad al Mac con cable
2. En Xcode, selecciona tu iPad del menú de dispositivos
3. Haz clic en **"Trust"** en el iPad si es la primera vez
4. Presiona `Cmd + R` para instalar la app
5. En el PDF Reader, activa "Enable Highlight"
6. **Dibuja** con el Apple Pencil sobre el texto
7. El texto bajo tu trazo se extraerá y guardará automáticamente

### Comportamiento con Apple Pencil
- ✏️ Solo el Pencil dibuja (dedos no dibujan)
- 🟡 Marcador amarillo semi-transparente
- 📝 Texto extraído automáticamente
- 🧹 Canvas se limpia después de cada trazo
- 💾 Highlights persisten en el PDF

---

## 🐛 Troubleshooting

### "No puedo seleccionar texto en el PDF"

**Solución:**
1. Asegúrate de que **Highlight Mode esté activo** (botón amarillo)
2. Usa **tap and hold** (no solo tap)
3. Si no funciona, prueba:
   - Cerrar y reabrir el PDF
   - Reiniciar el simulador
   - Limpiar build (`Cmd + Shift + K`) y recompilar

### "El toast no aparece"

Revisa la consola - el highlight puede haberse guardado aunque no veas el toast.
Busca: `✅ Highlight saved:` en los logs

### "No veo el highlight en Notes & Excerpts"

1. Verifica que volviste al proyecto correcto
2. Asegúrate de estar en la pestaña "Notes & Excerpts"
3. Scroll hacia abajo (el research question está primero)
4. Si no está, revisa la consola por errores de Core Data

### "El simulador es muy lento"

1. Menu: **I/O → Erase All Content and Settings**
2. Cierra otros simuladores abiertos
3. En Xcode: **Product → Clean Build Folder** (`Cmd + Shift + K`)

---

## 📊 Checklist de Funcionalidades

### En el Simulador ✅
- [x] Crear proyectos
- [x] Agregar research question
- [x] Importar PDF desde URL
- [x] Importar PDF desde Files
- [x] Abrir PDF en reader
- [x] Activar highlight mode
- [x] Seleccionar texto con tap-and-hold
- [x] Ver highlight amarillo
- [x] Ver toast de confirmación
- [x] Guardar excerpts en Core Data
- [x] Ver highlights en Notes & Excerpts
- [x] Navegación entre pantallas
- [x] Rich text editor en Notes

### Solo en iPad Real 🖊️
- [ ] Dibujar con Apple Pencil
- [ ] Extracción de texto desde dibujo
- [ ] Highlights con trazos libres
- [ ] Política "pencilOnly" (dedos no dibujan)

---

## 💡 Tips para Testing Eficiente

1. **Usa la URL de test**: El PDF de MIT se descarga rápido y tiene buen texto
2. **No reinicies la app**: Los datos persisten entre ejecuciones
3. **Observa la consola**: Los emojis en los logs te guían (✅, ❌, 📄, etc.)
4. **Test de smoke rápido**: URL → Highlight → Back → Check Notes (< 1 min)
5. **Limpia datos**: Borra la app del simulador para empezar fresco

---

## 🎨 Diferencias Visuales: Simulador vs iPad Real

| Característica | Simulador | iPad Real |
|----------------|-----------|-----------|
| Selección de texto | ✅ Handles azules | ✅ Handles azules |
| Apple Pencil drawing | ❌ No disponible | ✅ Marcador amarillo |
| Canvas overlay | 🟡 Alpha 0.1 | 🟡 Alpha 0.1 |
| Haptic feedback | ❌ No | ✅ Sí |
| Performance PDF | 🐢 Más lento | ⚡ Rápido |
| Zoom/scroll | ✅ Con trackpad | ✅ Con gestos |

---

## ✅ Confirmación de que Todo Funciona

Si puedes completar este flujo sin errores, **todo está funcionando correctamente**:

```
1. ✅ App abre sin crashes
2. ✅ Puedes crear un proyecto
3. ✅ Importar PDF desde URL funciona
4. ✅ PDF se abre en el reader
5. ✅ Botón "Enable Highlight" responde
6. ✅ Puedes seleccionar texto con tap-and-hold
7. ✅ Aparece highlight amarillo
8. ✅ Toast verde se muestra
9. ✅ Al volver, el texto está en "Notes & Excerpts"
10. ✅ Research question aparece al inicio de Notes
```

---

## 🚀 Próximos Pasos

Una vez que todo funcione en el simulador:

1. **Test en iPad real** con Apple Pencil
2. **Test edge cases**:
   - PDFs sin texto (solo imágenes)
   - PDFs protegidos/encriptados
   - URLs inválidas
   - PDFs muy grandes (>100 páginas)
3. **Test de persistencia**:
   - Cerrar app y reabrir
   - Highlights persisten
   - Projects persisten
4. **Test de UX**:
   - ¿Es intuitivo?
   - ¿Responde rápido?
   - ¿Los colores son apropiados?

---

¡Éxito con las pruebas! 🎉

Si encuentras bugs, revisa la consola y busca mensajes con ❌.

