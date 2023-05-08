FROM dart:stable AS mnote_build

ENV PORT=8080
WORKDIR /app
COPY pubspec.* ./
RUN dart pub get

COPY . .
RUN dart pub get --offline
RUN dart compile exe bin/mnote.dart -o bin/mnote

FROM scratch
COPY --from=mnote_build /runtime/ /
COPY --from=mnote_build /app/bin/mnote /app/bin/

EXPOSE ${PORT}
CMD ["/app/bin/mnote"]