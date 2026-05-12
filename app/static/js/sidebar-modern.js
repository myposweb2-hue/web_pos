/**
 * Modern Responsive Sidebar System
 * Production-ready JavaScript for sidebar toggle, collapse, and mobile drawer
 */

class ModernSidebar {
    constructor() {
        this.sidebar = document.getElementById('sidebar');
        this.overlay = document.getElementById('sidebarOverlay');
        this.toggle = document.getElementById('sidebarToggle');
        this.collapseBtn = document.getElementById('sidebarCollapse');
        this.closeBtn = document.getElementById('sidebarClose');
        this.body = document.body;
        
        this.isMobile = window.innerWidth < 1024;
        this.isCollapsed = JSON.parse(localStorage.getItem('sidebarCollapsed')) || false;
        
        this.init();
    }
    
    /**
     * Initialize sidebar system
     */
    init() {
        if (!this.sidebar || !this.toggle) return;
        
        this.setupEventListeners();
        this.restoreState();
        this.handleResize();
        this.setupKeyboardShortcuts();
        this.setupDropdowns();
    }
    
    /**
     * Setup all event listeners
     */
    setupEventListeners() {
        // Toggle button (mobile/tablet)
        if (this.toggle) {
            this.toggle.addEventListener('click', () => this.toggleSidebar());
        }
        
        // Collapse button (desktop)
        if (this.collapseBtn) {
            this.collapseBtn.addEventListener('click', () => this.toggleCollapse());
        }
        
        // Close button (mobile)
        if (this.closeBtn) {
            this.closeBtn.addEventListener('click', () => this.closeSidebar());
        }
        
        // Overlay click closes sidebar
        if (this.overlay) {
            this.overlay.addEventListener('click', () => this.closeSidebar());
        }
        
        // Prevent sidebar from closing when clicking inside
        if (this.sidebar) {
            this.sidebar.addEventListener('click', (e) => {
                e.stopPropagation();
            });
        }
        
        // Handle window resize
        window.addEventListener('resize', () => this.handleResize());
        
        // Escape key closes sidebar
        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape' && this.isMobile && this.sidebar?.classList.contains('show')) {
                this.closeSidebar();
            }
        });
        
        // Close sidebar when clicking on a nav link (mobile)
        const navLinks = this.sidebar?.querySelectorAll('.nav-link:not(.nav-dropdown > .nav-link)');
        navLinks?.forEach(link => {
            link.addEventListener('click', () => {
                if (this.isMobile) {
                    this.closeSidebar();
                }
            });
        });
        
        // Prevent body scroll when sidebar is open
        if (this.overlay) {
            this.overlay.addEventListener('touchmove', (e) => {
                if (this.sidebar?.classList.contains('show')) {
                    e.preventDefault();
                }
            }, { passive: false });
        }
    }
    
    /**
     * Toggle sidebar (mobile drawer)
     */
    toggleSidebar() {
        if (this.isMobile) {
            this.sidebar?.classList.toggle('show');
            this.overlay?.classList.toggle('show');
            this.preventBodyScroll(this.sidebar?.classList.contains('show'));
        }
    }
    
    /**
     * Open sidebar (mobile drawer)
     */
    openSidebar() {
        if (this.isMobile) {
            this.sidebar?.classList.add('show');
            this.overlay?.classList.add('show');
            this.preventBodyScroll(true);
        }
    }
    
    /**
     * Close sidebar (mobile drawer)
     */
    closeSidebar() {
        this.sidebar?.classList.remove('show');
        this.overlay?.classList.remove('show');
        this.preventBodyScroll(false);
    }
    
    /**
     * Toggle collapse state (desktop only)
     */
    toggleCollapse() {
        if (!this.isMobile) {
            this.isCollapsed = !this.isCollapsed;
            this.sidebar?.classList.toggle('collapsed');
            localStorage.setItem('sidebarCollapsed', JSON.stringify(this.isCollapsed));
            this.updateCollapseBtnIcon();
        }
    }
    
    /**
     * Update collapse button icon
     */
    updateCollapseBtnIcon() {
        if (this.collapseBtn) {
            const icon = this.collapseBtn.querySelector('i');
            if (icon) {
                if (this.isCollapsed) {
                    icon.className = 'fas fa-angle-right';
                } else {
                    icon.className = 'fas fa-angle-left';
                }
            }
        }
    }
    
    /**
     * Prevent/Allow body scroll
     */
    preventBodyScroll(prevent) {
        if (prevent) {
            this.body.style.overflow = 'hidden';
        } else {
            this.body.style.overflow = '';
        }
    }
    
    /**
     * Handle window resize
     */
    handleResize() {
        const wasMobile = this.isMobile;
        this.isMobile = window.innerWidth < 1024;
        
        // Changed from mobile to desktop
        if (wasMobile && !this.isMobile) {
            this.closeSidebar();
            this.sidebar?.classList.remove('show');
            this.overlay?.classList.remove('show');
            this.preventBodyScroll(false);
            
            if (this.isCollapsed) {
                this.sidebar?.classList.add('collapsed');
            }
        }
        
        // Changed from desktop to mobile
        if (!wasMobile && this.isMobile) {
            this.sidebar?.classList.remove('collapsed');
            this.isCollapsed = false;
        }
    }
    
    /**
     * Restore sidebar state from localStorage
     */
    restoreState() {
        if (!this.isMobile && this.isCollapsed) {
            this.sidebar?.classList.add('collapsed');
            this.updateCollapseBtnIcon();
        }
    }
    
    /**
     * Setup keyboard shortcuts
     */
    setupKeyboardShortcuts() {
        // Alt+B to toggle sidebar
        document.addEventListener('keydown', (e) => {
            if ((e.altKey || e.ctrlKey) && e.key === 'b') {
                e.preventDefault();
                if (this.isMobile) {
                    this.toggleSidebar();
                } else {
                    this.toggleCollapse();
                }
            }
        });
    }
    
    /**
     * Setup dropdown menus
     */
    setupDropdowns() {
        const dropdowns = this.sidebar?.querySelectorAll('.nav-dropdown > .nav-link');
        
        dropdowns?.forEach(dropdown => {
            dropdown.addEventListener('click', (e) => {
                e.preventDefault();
                
                const parent = dropdown.closest('.nav-dropdown');
                const wasOpen = parent?.classList.contains('open');
                
                // Close all other dropdowns
                this.sidebar?.querySelectorAll('.nav-dropdown.open').forEach(open => {
                    if (open !== parent) {
                        open.classList.remove('open');
                    }
                });
                
                // Toggle current
                if (parent) {
                    parent.classList.toggle('open');
                }
            });
        });
        
        // Keep dropdown open if a child link is active
        this.sidebar?.querySelectorAll('.nav-dropdown-link.active').forEach(activeLink => {
            const parent = activeLink.closest('.nav-dropdown');
            if (parent) {
                parent.classList.add('open');
            }
        });
    }
}

/**
 * Initialize sidebar on DOM ready
 */
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => {
        window.modernSidebar = new ModernSidebar();
    });
} else {
    window.modernSidebar = new ModernSidebar();
}

/**
 * Global helper functions
 */

/**
 * Toggle sidebar programmatically
 */
window.toggleSidebar = function() {
    if (window.modernSidebar) {
        window.modernSidebar.toggleSidebar();
    }
};

/**
 * Open sidebar programmatically
 */
window.openSidebar = function() {
    if (window.modernSidebar) {
        window.modernSidebar.openSidebar();
    }
};

/**
 * Close sidebar programmatically
 */
window.closeSidebar = function() {
    if (window.modernSidebar) {
        window.modernSidebar.closeSidebar();
    }
};

/**
 * Set active navigation item
 */
window.setActiveNavItem = function(selector) {
    const sidebar = document.getElementById('sidebar');
    sidebar?.querySelectorAll('.nav-link.active').forEach(item => {
        item.classList.remove('active');
    });
    
    const newActive = sidebar?.querySelector(selector);
    if (newActive) {
        newActive.classList.add('active');
        
        // Open parent dropdown if needed
        const parent = newActive.closest('.nav-dropdown');
        if (parent) {
            parent.classList.add('open');
        }
    }
};
