/*
 * Copyright 2009-2011 Roland Huss
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.jolokia.aji;

import java.io.IOException;

import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;

/**
 * A filter for dispatching between static and dynamic files
 * @author roland
 * @since 21.04.11
 */
public class DispatchFilter implements Filter {

    // prefix for static files
    private String staticPrefix;

    // prefix for dynamic content
    private String dynamicPrefix;

    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws ServletException, IOException {
        String context = ((HttpServletRequest) request).getContextPath();
        String uri = ((HttpServletRequest) request).getRequestURI();
        String path = uri.substring(context.length());
        // Aji handling
        if (uri.startsWith(context + staticPrefix)) {
            // Default servlet for static content
            chain.doFilter(request, response);
        } else {
            // Use the jolokia servlet
            request.getRequestDispatcher(dynamicPrefix + path).forward(request, response);
        }
    }

    public void init(FilterConfig config) throws javax.servlet.ServletException {
        staticPrefix = config.getInitParameter("staticPrefix");
        if (staticPrefix == null) {
            staticPrefix = "/app";
        }
        dynamicPrefix = config.getInitParameter("dynamicPrefix");
        if (dynamicPrefix == null) {
            dynamicPrefix = "/jolokia";
        }
    }

    public void destroy() {
    }

}
