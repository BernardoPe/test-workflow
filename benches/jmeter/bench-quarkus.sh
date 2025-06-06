cd ../../code || exit

./gradlew runQuarkus --no-daemon -Dorg.gradle.jvmargs="-Xms512M -Xmx16g" -DbenchTimeout=1 -Djdk.tracePinnedThreads > ../benches/jmeter/quarkus.log &
PID_GRADLE=$!

cd ../benches/jmeter || exit

sleep 1
while ! grep -m1 'Starting Quarkus Application' < quarkus.log; do
    sleep 1
done

PID_QUARKUS=$(grep -oP 'on PID \K[0-9]+' quarkus.log)

echo ":::::::::::::::::::::::::::::::     Gradle running PID = $PID_GRADLE"
echo ":::::::::::::::::::::::::::::::     Quarkus running PID = $PID_QUARKUS"

ROUTES=(
#  presentations/rocker
#  presentations/jstachio
#  presentations/pebble
#  presentations/freemarker
#  presentations/trimou
#  presentations/velocity
#  presentations/thymeleaf
#  presentations/htmlFlow
   presentations/reactive/htmlFlow
#  presentations/kotlinx
#  stocks/rocker
#  stocks/jstachio
#  stocks/pebble
#  stocks/freemarker
#  stocks/trimou
#  stocks/velocity
#  stocks/thymeleaf
#  stocks/htmlFlow
    stocks/reactive/htmlFlow
)

#
# Run Bench
#
echo "##########################################"
echo "############# RUN BENCH ##################"
echo "##########################################"
./run-jmeter.sh "${ROUTES[@]}" | tee quarkus-results.log


# Gracefully terminate the Spring Boot application.
# It will send a SIGTERM corresponding to Exit code 143.
kill $PID_GRADLE
kill $PID_QUARKUS

# Wait for the process to exit
wait $PID_GRADLE

echo ":::::::::::::::::::::::::::::::     Sync Bench Done"

cd ../../code || exit

./gradlew runQuarkusVirtual --no-daemon -DbenchTimeout=1 > ../benches/jmeter/quarkus.log &
PID_GRADLE=$!

cd ../benches/jmeter || exit

sleep 1
while ! grep -m1 'Starting Quarkus Application' < quarkus.log; do
    sleep 1
done

PID_QUARKUS=$(grep -oP 'on PID \K[0-9]+' quarkus.log)

echo ":::::::::::::::::::::::::::::::     Gradle running PID = $PID_GRADLE"
echo ":::::::::::::::::::::::::::::::     Quarkus running PID = $PID_QUARKUS"

#
# Run Bench
#
echo "##########################################"
echo "############# RUN BENCH ##################"
echo "##########################################"
./run-jmeter.sh "${ROUTES[@]}" | tee quarkus-virtual-results.log

if [ "$GH" != "true" ]; then
  kill $PID_GRADLE
  kill $PID_QUARKUS

  # Wait for the process to exit
  wait $PID_GRADLE
fi

echo ":::::::::::::::::::::::::::::::     Virtual Bench Done"