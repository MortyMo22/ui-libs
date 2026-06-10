RoundedUI/
├── init.lua                          ← точка входа (loadstring этот файл)
│
├── Core/
│   ├── Cleanup.lua                   ← RAII registry для connections/tweens
│   ├── Theme.lua                     ← все цвета и шрифтовые константы
│   ├── Animation.lua                 ← Anim module (Fast/Normal/Slow/Spring)
│   ├── Scale.lua                     ← Scale + Metrics, viewport-aware
│   └── Helpers.lua                   ← create, addCorner, withHoverAnim, isMobile
│
├── Systems/
│   ├── Keybind.lua                   ← глобальный реестр keybind callbacks
│   ├── ColorPicker.lua               ← standalone HSV popup
│   └── Notification.lua              ← toast system с queue и progress bar
│
├── Controls/
│   ├── CardAPI.lua                   ← переиспользуемый card builder
│   ├── SimpleControls.lua            ← Label, Separator, Button, TextBox, SearchBox, TextBind
│   ├── ToggleControls.lua            ← Toggle, ToggleWithBind, ToggleBind, ToggleColor, ToggleDualColor
│   ├── SelectControls.lua            ← Slider, DropDown, List
│   └── LayoutControls.lua           ← ScrollList, Card, Container, Pagination, VirtualList
│
└── UI/
    ├── Section.lua                   ← makeSection factory, sectionAPI
    └── Window.lua                    ← CreateWindow, tabs, drag, minimize
