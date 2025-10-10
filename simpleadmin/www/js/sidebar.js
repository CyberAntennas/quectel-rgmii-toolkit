// Sidebar functionality for Cyber Antennas inspired design
document.addEventListener('DOMContentLoaded', function() {
    const sidebar = document.getElementById('sidebar');
    const mainContent = document.getElementById('main-content');
    const footer = document.getElementById('footer');
    const sidebarToggle = document.getElementById('sidebar-toggle');
    const mobileMenuBtn = document.getElementById('mobile-menu-btn');
    const sidebarLogo = document.querySelector('.sidebar-logo');

    function toggleSidebar() {
        if (!sidebar || !mainContent) {
            return;
        }
        
        sidebar.classList.toggle('collapsed');
        mainContent.classList.toggle('expanded');
        if (footer) {
            footer.classList.toggle('expanded');
        }
        if (sidebarLogo) {
            sidebarLogo.classList.toggle('sidebar-logo-hidden');
        }
        // Store state in localStorage
        localStorage.setItem('sidebarCollapsed', sidebar.classList.contains('collapsed'));
    }
    
    // Sidebar collapse/expand functionality
    if (sidebarToggle) {
        sidebarToggle.addEventListener('click', function(e) {
            e.preventDefault();
            e.stopPropagation();
            toggleSidebar();
        }, true);
    }
    
    // Mobile menu functionality
    if (mobileMenuBtn) {
        mobileMenuBtn.addEventListener('click', function() {
            sidebar.classList.toggle('mobile-open');
        });
    }
    
    // Close mobile menu when clicking outside
    document.addEventListener('click', function(event) {
        if (window.innerWidth <= 768) {
            if (!sidebar.contains(event.target) && 
                mobileMenuBtn && !mobileMenuBtn.contains(event.target)) {
                sidebar.classList.remove('mobile-open');
            }
        }
    });
    
    // Restore sidebar state from localStorage
    const sidebarCollapsed = localStorage.getItem('sidebarCollapsed') === 'true';
    if (sidebarCollapsed) {
        sidebar.classList.add('collapsed');
        mainContent.classList.add('expanded');
        if (footer) {
            footer.classList.add('expanded');
        }
        if (sidebarLogo) {
            sidebarLogo.classList.add('sidebar-logo-hidden');
        }
    }
    
    // Set active nav item based on current page
    const currentPath = window.location.pathname;
    const navLinks = document.querySelectorAll('.nav-link');
    
    navLinks.forEach(link => {
        const linkPath = new URL(link.href).pathname;
        if (linkPath === currentPath || 
            (currentPath === '/' && linkPath === '/') ||
            (currentPath === '/index.html' && linkPath === '/')) {
            link.classList.add('active');
        } else {
            link.classList.remove('active');
        }
    });
    
    // Handle window resize for responsive behavior
    window.addEventListener('resize', function() {
        if (window.innerWidth > 768) {
            sidebar.classList.remove('mobile-open');
        }
    });
});
