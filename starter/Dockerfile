# Use latest Dart image and name build stage
FROM dart:stable AS mnote_build
ENV PORT=8080
WORKDIR /app

# Copy pubspec prefixed files into current dir and get packages
COPY pubspec.* ./
RUN dart pub get

# Copy everything from current dir
COPY . .
RUN dart pub get --offline
RUN dart compile exe bin/mnote.dart -o bin/mnote

# Start new build stage using 'scratch' base image
FROM scratch
COPY --from=mnote_build /runtime/ /
COPY --from=mnote_build /app/bin/mnote /app/bin/
EXPOSE $PORT

# Run the server
CMD ["/app/bin/mnote"]