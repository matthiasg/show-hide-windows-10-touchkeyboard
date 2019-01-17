# show-hide-windows-10-touchkeyboard

We needed two executables to force showing and hiding the touch keyboard on Windows 10 devices (1803+ but previous should work too) triggered from Electron.

Sadly there does not seem to be a simple and documented API to perform that. Electrons Chromium should trigger it automatically, but sadly there are a number of scenarios when it doesn't do that correctly or reliably and some of the fixes that came in recently are not available in Electron yet.

So based on an undocumented API (toggle) and some added heuristics (to check whether the keyboard is open) I wrote this code. Some of the code is taken/rewritten from a number of posts around the web and my sincere thanks go out to the people in the forums such as https://stackoverflow.com/questions/47187216/determine-if-windows-10-touch-keyboard-is-visible-or-hidden

If it helps someone great, use it, comments are welcome but the code written here is not best-practice and I will not fix bugs that I am not affected by. Both sources are practically the same but we did not want to pass a parameter thus the duplication.

# Electron Usage

We use it by loading content in an IFrame  and add a `focusin` listener and send an ipcRenderer IPC call which causes the main electron process to execute the executables.

```javascript
frame.contentDocument.body.addEventListener('focusin', (event) => {
   const tag = event.target.tagName.toLowerCase()

   switch(tag) {
      case 'input':
         if (event.target.type === 'range' ||
              event.target.type === 'radio' ||
              event.target.type === 'checkbox' ||
              event.target.type === 'select' ) {
            return
          } 
        case 'textarea': 
          console.log('input or textarea focused. sending show-keyboard ...')
          ipcRenderer.send('show-keyboard')
          break
        default:
          console.log('focus outside of input. sending hide-keyboard ...')
          ipcRenderer.send('hide-keyboard')
   }
})
```

In the main host file you could then receive these events and trigger the executables:

```javascript
const electron = require('electron')
const { spawn, execSync } = require('child_process')

...

mainWindow.once('show', () => {
 
 ...
 
 
 electron.ipcMain.on('show-keyboard',() => {
   console.log('TRACE: showing keyboard ...')

   try {
     execSync('show-touchkeyboard.exe', { cwd: __dirname })
     console.log('started touch keyboard')
   } catch (error) {
     console.error('Error starting show touch keyboard', error)
   }
 })

 electron.ipcMain.on('hide-keyboard',() => {
   console.log('TRACE: hiding keyboard ...')

   try {
     execSync('hide-touchkeyboard.exe', { cwd: __dirname })
     console.log('hidden touch keyboard')
   } catch (error) {
     console.error('Error starting hide touch keyboard', error)
   }
 })
})

```

Cheers.

PS:

This code works best when `DisableNewKeyboardExperience` under `HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\TabletTip\1.7` is set to `1` (Thanks to https://social.msdn.microsoft.com/profile/technutta?type=forum&referrer=https://social.msdn.microsoft.com/Forums/windowsdesktop/en-US/aba8e07c-7d44-42a9-a9eb-d7387a201899/on-screen-keyboard-not-working-in-custom-shell-windows-10-pro-1709-and-1803?forum=tabletandtouch&prof=required)

```
Select key [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\TabletTip\1.7]
Create value [New] ⇒ [DWORD (32 bit) value] 
Change the value name to [DisableNewKeyboardExperience] 
Change the name [DisableNewKeyboardExperience] Double-click to open the value data, change it to 1
 Restart the PC 
```

