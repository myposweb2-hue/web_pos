/* ====================================
   GLOBAL FETCH INTERCEPTOR
   ==================================== */

const originalFetch = window.fetch;
window.fetch = function(...args) {
    return originalFetch.apply(this, args).then(response => {
        if (response.status === 401) {
            // Session expired
            location.href = '/auth/login';
        }
        return response;
    }).catch(error => {
        console.error('Fetch error:', error);
        throw error;
    });
};

/* ====================================
   AUTO-DISMISS ALERTS
   ==================================== */

document.addEventListener('DOMContentLoaded', function() {
    const alerts = document.querySelectorAll('.alert');
    alerts.forEach(alert => {
        setTimeout(() => {
            const bsAlert = new bootstrap.Alert(alert);
            bsAlert.close();
        }, 5000);
    });
});

/* ====================================
   TOOLTIP INITIALIZATION
   ==================================== */

document.addEventListener('DOMContentLoaded', function() {
    const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
    const tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
        return new bootstrap.Tooltip(tooltipTriggerEl);
    });
});

/* ====================================
   SIDEBAR DROPDOWN TOGGLE
   ==================================== */

document.addEventListener('DOMContentLoaded', function() {
    const dropdownLinks = document.querySelectorAll('.nav-dropdown > .nav-link');
    
    dropdownLinks.forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault();
            const parentItem = this.parentElement;
            const isOpen = parentItem.classList.contains('open');
            
            // Close all other dropdowns
            document.querySelectorAll('.nav-dropdown.open').forEach(item => {
                if (item !== parentItem) {
                    item.classList.remove('open');
                }
            });
            
            // Toggle current dropdown
            parentItem.classList.toggle('open');
        });
    });
    
    // Close dropdown when a submenu item is clicked
    document.querySelectorAll('.nav-dropdown-link').forEach(link => {
        link.addEventListener('click', function() {
            // On mobile, close sidebar after selection
            if (window.innerWidth < 992) {
                const sidebar = document.getElementById('sidebar');
                if (sidebar) {
                    sidebar.classList.remove('open');
                    const overlay = document.getElementById('sidebarOverlay');
                    if (overlay) overlay.classList.remove('active');
                }
            }
        });
    });
});

/* ====================================
   NOTIFICATION HELPER
   ==================================== */

function showNotification(title, message, type = 'info') {
    const notifDiv = document.createElement('div');
    notifDiv.className = `alert alert-${type} alert-dismissible fade show`;
    notifDiv.setAttribute('role', 'alert');
    notifDiv.innerHTML = `
        <strong>${title}</strong> ${message}
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    `;
    
    const mainContent = document.querySelector('.main-content');
    if (mainContent) {
        mainContent.insertBefore(notifDiv, mainContent.firstChild);
        
        setTimeout(() => {
            const bsAlert = new bootstrap.Alert(notifDiv);
            bsAlert.close();
        }, 5000);
    }
}

/* ====================================
   KEYBOARD SHORTCUTS
   ==================================== */

const KEYBOARD_SHORTCUTS = {
    'n': () => window.location.href = '/sales/sales',
    'c': () => window.location.href = '/customers/customers',
    'p': () => window.location.href = '/inventory/inventory',
    'h': () => window.location.href = '/sales/sales_history',
    'r': () => window.location.href = '/sales/returns',
    'b': () => window.location.href = '/sales/bills', // Hold bills if available
    'e': () => window.location.href = '/expenses/expenses',
    't': () => window.location.href = '/reports/reports'
};

document.addEventListener('DOMContentLoaded', function() {
    // Keyboard shortcut listener
    document.addEventListener('keydown', function(e) {
        // Don't trigger shortcuts when typing in input fields
        if (['INPUT', 'TEXTAREA'].includes(e.target.tagName)) {
            // Exception: Allow ? to open help in input fields
            if (e.key === '?' || (e.shiftKey && e.key === '/')) {
                e.preventDefault();
                openShortcutHelp();
            }
            return;
        }
        
        // Check for ? or Shift+/
        if (e.key === '?' || (e.shiftKey && e.key === '/')) {
            e.preventDefault();
            openShortcutHelp();
            return;
        }
        
        // Check for other shortcuts
        if (KEYBOARD_SHORTCUTS[e.key.toLowerCase()]) {
            e.preventDefault();
            KEYBOARD_SHORTCUTS[e.key.toLowerCase()]();
        }
    });
});

function openShortcutHelp() {
    const shortcutModal = document.getElementById('shortcutModal');
    if (shortcutModal) {
        const bsModal = new bootstrap.Modal(shortcutModal);
        bsModal.show();
    }
}

document.addEventListener('DOMContentLoaded', function() {
    const shortcutHelpBtn = document.getElementById('shortcutHelpBtn');
    if (shortcutHelpBtn) {
        shortcutHelpBtn.addEventListener('click', openShortcutHelp);
    }
});

/* ====================================
   QUICK NAVIGATION BUTTONS
   ==================================== */

document.addEventListener('DOMContentLoaded', function() {
    // Quick nav buttons already have href, no additional JS needed
    // But we can add some keyboard support
});

/* ====================================
   ON-SCREEN KEYBOARD
   ==================================== */

let lastFocusedInput = null;

function buildOnScreenKeyboard() {
    const keyboardContainer = document.getElementById('onScreenKeyboard');
    if (!keyboardContainer) {
        const keyboard = document.createElement('div');
        keyboard.id = 'onScreenKeyboard';
        keyboard.className = 'on-screen-keyboard';
        keyboard.innerHTML = `
            <div class="keyboard-row">
                <button class="keyboard-key">1</button>
                <button class="keyboard-key">2</button>
                <button class="keyboard-key">3</button>
                <button class="keyboard-key">4</button>
                <button class="keyboard-key">5</button>
                <button class="keyboard-key">6</button>
                <button class="keyboard-key">7</button>
                <button class="keyboard-key">8</button>
                <button class="keyboard-key">9</button>
                <button class="keyboard-key">0</button>
            </div>
            <div class="keyboard-row">
                <button class="keyboard-key">Q</button>
                <button class="keyboard-key">W</button>
                <button class="keyboard-key">E</button>
                <button class="keyboard-key">R</button>
                <button class="keyboard-key">T</button>
                <button class="keyboard-key">Y</button>
                <button class="keyboard-key">U</button>
                <button class="keyboard-key">I</button>
                <button class="keyboard-key">O</button>
                <button class="keyboard-key">P</button>
            </div>
            <div class="keyboard-row">
                <button class="keyboard-key">A</button>
                <button class="keyboard-key">S</button>
                <button class="keyboard-key">D</button>
                <button class="keyboard-key">F</button>
                <button class="keyboard-key">G</button>
                <button class="keyboard-key">H</button>
                <button class="keyboard-key">J</button>
                <button class="keyboard-key">K</button>
                <button class="keyboard-key">L</button>
            </div>
            <div class="keyboard-row">
                <button class="keyboard-key">Z</button>
                <button class="keyboard-key">X</button>
                <button class="keyboard-key">C</button>
                <button class="keyboard-key">V</button>
                <button class="keyboard-key">B</button>
                <button class="keyboard-key">N</button>
                <button class="keyboard-key">M</button>
            </div>
            <div class="keyboard-row">
                <button class="keyboard-key">.</button>
                <button class="keyboard-key">,</button>
                <button class="keyboard-key">-</button>
                <button class="keyboard-key">+</button>
                <button class="keyboard-key">@</button>
                <button class="keyboard-key">$</button>
                <button class="keyboard-key">%</button>
                <button class="keyboard-key">/</button>
            </div>
            <div class="keyboard-row">
                <button class="keyboard-key">Space</button>
                <button class="keyboard-key backspace">⌫ Backspace</button>
                <button class="keyboard-key enter">↵ Enter</button>
                <button class="keyboard-key close">✕ Close</button>
            </div>
        `;
        document.body.appendChild(keyboard);
    }
    
    // Add event listeners
    const keyboardKeys = document.querySelectorAll('.keyboard-key');
    keyboardKeys.forEach(key => {
        key.addEventListener('click', function(e) {
            e.preventDefault();
            const text = this.textContent.trim();
            
            if (text === 'Space') {
                insertTextAtCaret(' ');
            } else if (text === '⌫ Backspace') {
                deleteLastCharacter();
            } else if (text === '↵ Enter') {
                insertTextAtCaret('\n');
            } else if (text === '✕ Close') {
                closeOnScreenKeyboard();
            } else {
                insertTextAtCaret(text.toLowerCase());
            }
        });
    });
}

function insertTextAtCaret(text) {
    if (!lastFocusedInput) {
        alert('Please click on an input field first');
        return;
    }
    
    const input = lastFocusedInput;
    const startPos = input.selectionStart;
    const endPos = input.selectionEnd;
    const value = input.value;
    
    input.value = value.substring(0, startPos) + text + value.substring(endPos);
    input.selectionStart = input.selectionEnd = startPos + text.length;
    input.focus();
}

function deleteLastCharacter() {
    if (!lastFocusedInput) return;
    
    const input = lastFocusedInput;
    const startPos = input.selectionStart;
    
    if (startPos > 0) {
        input.value = input.value.substring(0, startPos - 1) + input.value.substring(input.selectionEnd);
        input.selectionStart = input.selectionEnd = startPos - 1;
        input.focus();
    }
}

document.addEventListener('DOMContentLoaded', function() {
    const onScreenKeyboardBtn = document.getElementById('onScreenKeyboardBtn');
    if (onScreenKeyboardBtn) {
        onScreenKeyboardBtn.addEventListener('click', function() {
            buildOnScreenKeyboard();
            const keyboard = document.getElementById('onScreenKeyboard');
            if (keyboard) {
                keyboard.classList.toggle('active');
            }
        });
    }
    
    // Capture focus on input fields
    document.addEventListener('focus', function(e) {
        if (['INPUT', 'TEXTAREA'].includes(e.target.tagName)) {
            lastFocusedInput = e.target;
        }
    }, true);
});

function closeOnScreenKeyboard() {
    const keyboard = document.getElementById('onScreenKeyboard');
    if (keyboard) {
        keyboard.classList.remove('active');
        if (lastFocusedInput) {
            lastFocusedInput.focus();
        }
    }
}

/* ====================================
   FULLSCREEN TOGGLE
   ==================================== */

let isFullscreen = false;

document.addEventListener('DOMContentLoaded', function() {
    const fullscreenBtn = document.getElementById('fullscreenBtn');
    if (fullscreenBtn) {
        fullscreenBtn.addEventListener('click', toggleFullscreen);
    }
    
    // Ctrl+Shift+F shortcut for fullscreen
    document.addEventListener('keydown', function(e) {
        if (e.ctrlKey && e.shiftKey && e.key === 'F') {
            e.preventDefault();
            toggleFullscreen();
        }
    });
    
    // Handle fullscreen change event
    document.addEventListener('fullscreenchange', handleFullscreenChange);
    document.addEventListener('webkitfullscreenchange', handleFullscreenChange);
    document.addEventListener('mozfullscreenchange', handleFullscreenChange);
    document.addEventListener('msfullscreenchange', handleFullscreenChange);
});

function toggleFullscreen() {
    const elem = document.documentElement;
    
    if (!document.fullscreenElement && !document.webkitFullscreenElement) {
        // Enter fullscreen
        if (elem.requestFullscreen) {
            elem.requestFullscreen();
        } else if (elem.webkitRequestFullscreen) {
            elem.webkitRequestFullscreen();
        } else if (elem.mozRequestFullScreen) {
            elem.mozRequestFullScreen();
        } else if (elem.msRequestFullscreen) {
            elem.msRequestFullscreen();
        }
        isFullscreen = true;
    } else {
        // Exit fullscreen
        if (document.exitFullscreen) {
            document.exitFullscreen();
        } else if (document.webkitExitFullscreen) {
            document.webkitExitFullscreen();
        } else if (document.mozCancelFullScreen) {
            document.mozCancelFullScreen();
        } else if (document.msExitFullscreen) {
            document.msExitFullscreen();
        }
        isFullscreen = false;
    }
}

function handleFullscreenChange() {
    const fullscreenIcon = document.getElementById('fullscreenIcon');
    if (!fullscreenIcon) return;
    
    if (document.fullscreenElement || document.webkitFullscreenElement) {
        fullscreenIcon.classList.remove('fa-expand');
        fullscreenIcon.classList.add('fa-compress');
        isFullscreen = true;
    } else {
        fullscreenIcon.classList.remove('fa-compress');
        fullscreenIcon.classList.add('fa-expand');
        isFullscreen = false;
        
        // Show prompt when user exits fullscreen
        if (isFullscreen === false) {
            showNotification('Info', 'You have exited fullscreen mode.', 'info');
        }
    }
}

/* ====================================
   CALCULATOR FUNCTIONALITY
   ==================================== */

let calcDisplay = '0';
let calcOperand1 = null;
let calcOperator = null;
let calcOperand2 = null;

function calcAppend(value) {
    const display = document.getElementById('calcDisplay');
    
    if (value === 'C') {
        calcReset();
    } else if (value === 'DEL') {
        if (display.value.length > 1) {
            display.value = display.value.slice(0, -1);
        } else {
            display.value = '0';
        }
    } else if (['+', '-', '*', '/', '%'].includes(value)) {
        calcOperand1 = parseFloat(display.value);
        calcOperator = value;
        display.value = '0';
    } else if (value === '.') {
        if (!display.value.includes('.')) {
            display.value += '.';
        }
    } else {
        if (display.value === '0') {
            display.value = value;
        } else {
            display.value += value;
        }
    }
}

function calcResult() {
    const display = document.getElementById('calcDisplay');
    
    if (calcOperand1 !== null && calcOperator) {
        calcOperand2 = parseFloat(display.value);
        let result = 0;
        
        switch(calcOperator) {
            case '+':
                result = calcOperand1 + calcOperand2;
                break;
            case '-':
                result = calcOperand1 - calcOperand2;
                break;
            case '*':
                result = calcOperand1 * calcOperand2;
                break;
            case '/':
                result = calcOperand1 / calcOperand2;
                break;
            case '%':
                result = calcOperand1 % calcOperand2;
                break;
        }
        
        display.value = Math.round(result * 10000) / 10000;
        calcOperand1 = null;
        calcOperator = null;
        calcOperand2 = null;
    }
}

function calcReset() {
    const display = document.getElementById('calcDisplay');
    display.value = '0';
    calcOperand1 = null;
    calcOperator = null;
    calcOperand2 = null;
}

// Calculator keyboard support
document.addEventListener('DOMContentLoaded', function() {
    const calculator = document.getElementById('draggableCalculator');
    if (calculator) {
        calculator.addEventListener('keydown', function(e) {
            if (['+', '-', '*', '/', '%'].includes(e.key)) {
                e.preventDefault();
                calcAppend(e.key);
            } else if (e.key === 'Enter') {
                e.preventDefault();
                calcResult();
            } else if (e.key === 'Backspace') {
                e.preventDefault();
                calcAppend('DEL');
            } else if (e.key === 'c' || e.key === 'C') {
                e.preventDefault();
                calcAppend('C');
            }
        });
    }
});

/* ====================================
   DRAGGABLE CALCULATOR
   ==================================== */

document.addEventListener('DOMContentLoaded', function() {
    const calculator = document.getElementById('draggableCalculator');
    const header = document.getElementById('calcHeader');
    const closeBtn = document.getElementById('closeCalcBtn');
    const calculatorBtn = document.getElementById('calculatorBtn');
    
    let isDragging = false;
    let currentX;
    let currentY;
    let initialX;
    let initialY;
    
    if (header) {
        header.addEventListener('mousedown', startDrag);
    }
    
    if (closeBtn) {
        closeBtn.addEventListener('click', function() {
            calculator.style.display = 'none';
        });
    }
    
    if (calculatorBtn) {
        calculatorBtn.addEventListener('click', function() {
            calculator.style.display = calculator.style.display === 'none' ? 'block' : 'none';
        });
    }
    
    function startDrag(e) {
        isDragging = true;
        initialX = e.clientX - calculator.offsetLeft;
        initialY = e.clientY - calculator.offsetTop;
        document.addEventListener('mousemove', drag);
        document.addEventListener('mouseup', stopDrag);
    }
    
    function drag(e) {
        if (!isDragging) return;
        currentX = e.clientX - initialX;
        currentY = e.clientY - initialY;
        calculator.style.left = currentX + 'px';
        calculator.style.top = currentY + 'px';
        calculator.style.right = 'auto';
        calculator.style.bottom = 'auto';
    }
    
    function stopDrag() {
        isDragging = false;
        document.removeEventListener('mousemove', drag);
        document.removeEventListener('mouseup', stopDrag);
    }
});

/* ====================================
   GLOBAL TIMESTAMP UTILITY FUNCTIONS
   ==================================== */

window.formatTimestamp = function(timestamp, includeTime = true) {
    if (!timestamp) return '-';
    
    try {
        let dateStr = String(timestamp).trim();
        if (!dateStr.endsWith('Z') && !dateStr.includes('+')) {
            dateStr += 'Z';
        }
        
        const date = new Date(dateStr);
        if (isNaN(date.getTime())) {
            console.warn('Invalid timestamp:', timestamp);
            return timestamp;
        }
        
        const userTimezone = Intl.DateTimeFormat().resolvedOptions().timeZone;
        
        if (includeTime) {
            return date.toLocaleString('en-GB', {
                year: 'numeric',
                month: '2-digit',
                day: '2-digit',
                hour: '2-digit',
                minute: '2-digit',
                second: '2-digit',
                hour12: false,
                timeZone: userTimezone
            });
        } else {
            return date.toLocaleDateString('en-GB', {
                year: 'numeric',
                month: '2-digit',
                day: '2-digit',
                timeZone: userTimezone
            });
        }
    } catch(error) {
        console.error('Error formatting timestamp:', timestamp, error);
        return timestamp;
    }
};

window.formatTableTimestamps = function() {
    document.querySelectorAll('[data-timestamp]').forEach(el => {
        const timestamp = el.getAttribute('data-timestamp');
        el.textContent = window.formatTimestamp(timestamp, true);
    });
    
    document.querySelectorAll('[data-date]').forEach(el => {
        const timestamp = el.getAttribute('data-date');
        el.textContent = window.formatTimestamp(timestamp, false);
    });
};

window.formatDynamicTimestamps = function(container = document) {
    if (!container) container = document;
    
    const timeElements = container.querySelectorAll('[data-timestamp]');
    timeElements.forEach(el => {
        if (el.textContent && !el.textContent.includes('/')) {
            const timestamp = el.getAttribute('data-timestamp') || el.textContent;
            el.textContent = window.formatTimestamp(timestamp, true);
        }
    });
};

/* Call on page load */
document.addEventListener('DOMContentLoaded', function() {
    formatTableTimestamps();
});

/* ====================================
   ADDITIONAL UTILITY FUNCTIONS
   ==================================== */

// Header Search
document.addEventListener('DOMContentLoaded', function() {
    const headerSearchInput = document.getElementById('headerSearchInput');
    if (headerSearchInput) {
        headerSearchInput.addEventListener('keyup', function(e) {
            if (e.key === 'Enter' || this.value.length >= 2) {
                const searchTerm = this.value.trim();
                if (searchTerm) {
                    window.location.href = '/sales/sales?search=' + encodeURIComponent(searchTerm);
                }
            }
        });
    }
});

// Notifications polling
document.addEventListener('DOMContentLoaded', function() {
    function loadNotifications() {
        fetch('/api/notifications')
            .then(response => {
                if (!response.ok) {
                    throw new Error(`HTTP error! status: ${response.status}`);
                }
                const contentType = response.headers.get('content-type');
                if (!contentType || !contentType.includes('application/json')) {
                    throw new Error('Response is not JSON');
                }
                return response.json();
            })
            .then(data => {
                const notificationList = document.getElementById('notificationList');
                const badge = document.querySelector('.notification-badge');
                
                if (notificationList && data.notifications) {
                    if (data.notifications.length === 0) {
                        notificationList.innerHTML = '<li class="notification-item text-center text-muted py-3">No notifications</li>';
                    } else {
                        let html = '';
                        data.notifications.forEach(function(notif) {
                            let iconClass = 'fa-info-circle';
                            let bgClass = 'bg-info-light';
                            let textClass = 'text-info';
                            
                            if (notif.type === 'success') {
                                iconClass = 'fa-check-circle';
                                bgClass = 'bg-success-light';
                                textClass = 'text-success';
                            } else if (notif.type === 'warning') {
                                iconClass = 'fa-exclamation-triangle';
                                bgClass = 'bg-warning-light';
                                textClass = 'text-warning';
                            }
                            
                            html += '<li class="notification-item">' +
                                '<a class="dropdown-item d-flex align-items-start" href="#">' +
                                '<div class="notification-icon ' + bgClass + ' ' + textClass + '"><i class="fas ' + iconClass + '"></i></div>' +
                                '<div class="notification-content">' +
                                '<p class="mb-0"><strong>' + notif.title + '</strong> ' + notif.message + '</p>' +
                                '<small class="text-muted">' + notif.time + '</small>' +
                                '</div>' +
                                '</a>' +
                                '</li>';
                        });
                        notificationList.innerHTML = html;
                    }
                }
                
                if (badge && data.count > 0) {
                    badge.textContent = data.count > 9 ? '9+' : data.count;
                    badge.style.display = 'inline-block';
                }
            })
            .catch(function(error) {
                console.error('Error loading notifications:', error);
            });
    }
    
    loadNotifications();
    setInterval(loadNotifications, 60000);
});

// Company switcher
function switchCompany(companyId) {
    const csrfToken = document.querySelector('meta[name="csrf-token"]');
    const token = csrfToken ? csrfToken.content : '';
    
    fetch('/companies/api/companies/switch', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-CSRFToken': token
        },
        body: JSON.stringify({ company_id: companyId })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            location.reload();
        } else {
            alert(data.error || 'Failed to switch company');
        }
    })
    .catch(error => {
        console.error('Error:', error);
        alert('Error switching company');
    });
}

// Currency symbol replacement
document.addEventListener('DOMContentLoaded', function() {
    function replaceCurrencySymbols() {
        fetch('/api/currency-symbol')
            .then(response => response.json())
            .then(data => {
                const newSymbol = data.currency_symbol || 'Rs. ';
                document.querySelectorAll('h1, h2, h3, h4, h5, h6, p, span, td, div, li').forEach(element => {
                    if (element.textContent && element.textContent.includes('₨')) {
                        element.innerHTML = element.innerHTML.replace(/₨/g, newSymbol);
                    }
                });
            })
            .catch(error => console.error('Error loading currency symbol:', error));
    }
    replaceCurrencySymbols();
});
