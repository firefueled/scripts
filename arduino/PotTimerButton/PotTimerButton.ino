const int buttonPin = 10;
const int ledPin = 13;
const int relayPin = 12;
const int potPin = A0;
const int minTime = 5;
const int maxTime = 120;

int buttonState = 0;
int potState = 0;
bool relayState = false;
float relayOnStart = 0;
float relayOnEnd = 0;
float delayTime = 0;

void setup() {
  Serial.begin(9600);
  pinMode(buttonPin, INPUT);
  pinMode(potPin, INPUT);
  pinMode(ledPin, OUTPUT);
  pinMode(relayPin, OUTPUT);
  digitalWrite(relayPin, HIGH); //reverse

  digitalWrite(ledPin, HIGH);
  delay(100);
  digitalWrite(ledPin, LOW);
  delay(100);
  digitalWrite(ledPin, HIGH);
  delay(100);
  digitalWrite(ledPin, LOW);
  
  delay(500);
  digitalWrite(ledPin, HIGH);
  delay(500);
  digitalWrite(ledPin, LOW);
}

void loop() {
  buttonState = digitalRead(buttonPin);
 
  if (buttonState == HIGH) {
    relayState = true;
  }

  if (relayState) {
    if (relayOnStart == 0) {
      potState = analogRead(potPin);
      relayOnStart = millis();
      relayOnEnd = map(potState, 1023, 0, minTime, maxTime) * 1000 + relayOnStart;
      Serial.println((relayOnEnd - relayOnStart) / 1000);
      
      digitalWrite(ledPin, HIGH);
      digitalWrite(relayPin, LOW);  
    
    } else if (relayOnStart < relayOnEnd) {
      relayOnStart += millis() - relayOnStart;
    
    } else {
      digitalWrite(ledPin, LOW);
      digitalWrite(relayPin, HIGH);  
      relayOnEnd = 0;
      relayOnStart = 0;
      relayState = false;
    }
  }
}