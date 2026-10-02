package filter;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebFilter("/*")
public class AuthenticationFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        String path = httpRequest.getRequestURI().substring(httpRequest.getContextPath().length());

        // Allow static resources, login, and logout
        if (path.startsWith("/css/") || path.startsWith("/js/") || path.startsWith("/images/") 
            || path.equals("/login") || path.equals("/login.jsp") || path.equals("/logout") || path.equals("/index.jsp") || path.equals("/") || path.equals("/test") || path.equals("/test.jsp")) {
            chain.doFilter(request, response);
            return;
        }

        HttpSession session = httpRequest.getSession(false);
        boolean isLoggedIn = (session != null && session.getAttribute("loggedInUser") != null);

        if (isLoggedIn) {
            String role = (String) session.getAttribute("userRole");
            
            // Role-based protection
            if (path.startsWith("/admin/")) {
                if ("ADMIN".equals(role)) {
                    chain.doFilter(request, response);
                } else {
                    httpResponse.sendError(HttpServletResponse.SC_FORBIDDEN, "Unauthorized Access - Admin Role Required");
                }
            } else if (path.startsWith("/user/")) {
                if ("USER".equals(role)) {
                    chain.doFilter(request, response);
                } else {
                    httpResponse.sendError(HttpServletResponse.SC_FORBIDDEN, "Unauthorized Access - User Role Required");
                }
            } else {
                // Allow other authenticated pages (if any exist that are not inside admin/ or user/)
                chain.doFilter(request, response);
            }
        } else {
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/login.jsp");
        }
    }

    @Override
    public void destroy() {}
}
