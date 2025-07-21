def XForwardedForMiddleware(get_response):
    def middleware(request):
        if 'x-forwarded-for' in request.headers:
            request.META['REMOTE_ADDR'] = request.headers['x-forwarded-for'].split(',')[0].strip()
        elif 'cf-connecting-ip' in request.headers:
            request.META['REMOTE_ADDR'] = request.headers['cf-connecting-ip'].split(',')[0].strip()

        response = get_response(request)

        return response
    return middleware
