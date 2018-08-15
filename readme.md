This is based on the Prancersize application developed in this tutorial:
[HealthKit Tutorial With Swift: Getting Started](https://www.raywenderlich.com/459-healthkit-tutorial-with-swift-getting-started)

It works with both XCode Version 10.0 beta 5 (10L221o) and Version 9.4.1 (9F2000). Note that importing files in HL7 FHIR format (not done yet) may require the 10.0 beta version.

It was modified by Ketema to:
* Add a button which imports Health Records in the CDA format (XML).

It was modified by Patrick to:
* Import a different CDA file (the file is embedded in appication resources - see `MedicalRecordsSample.xml` and `SummaryOfCare.xml`)
* Add better error handling so access to individual data fields can fail (for example, if the user has not given permission to share weight), but the others will succeed (if the app has permission to read them, and there are values to read).
* Take all of the available attributes and the last available measurement for height and weight, encode them in JSON and send a POST to localhost:3000, like this:

```JSON
{
    "memberId": "XEA123456",
    "attributes": [
      {
        "attributeType": "DOB",
        "attributeValue": "1961-11-27"
      },
      {
        "attributeType": "BiologicalSex",
        "attributeValue": "Male"
      },
      {
        "attributeType": "BloodType",
        "attributeValue": "A+"
      },
      {
        "attributeType": "FitzpatrickSkinType",
        "attributeValue": "I"
      },
      {
        "attributeType": "WheelchairUse",
        "attributeValue": "no"
      }
    ],
    "measurements": [
      {
        "measurementValue": "113.85",
        "unitOfMeasure": "Kg",
        "endDate": "2018-08-02T23:37:00Z",
        "startDate": "2018-08-02T23:37:00Z",
        "measurementType": "Weight",
        "uuid": "BE15F14C-6A1E-463C-89C3-D38743DD3ED0"
      },
      {
        "measurementValue": "1.98",
        "unitOfMeasure": "M",
        "endDate": "2018-08-02T18:50:00Z",
        "startDate": "2018-08-02T18:50:00Z",
        "measurementType": "Height",
        "uuid": "413A667E-63F2-40A2-9510-C02C1EAE9D65"
      }
    ],
    "id": 1
  }
```

Notes:
* Member ID is fabricated. Presumable, if a member had authenticated, we would have their ID.
* Attributes are things that seldom or never change. Measurement change more frequently, so it's improtant to capture the date that measurement was taken.
* The app will always send the latest measurement, even if it has already sent it before.
* The app will not send previous measurements, even if they have never been sent.
* Each measurment includes a UUID, so it should be easy for a server to reject measurements it has already seen.
* All of this is straightforward to change. For example, the app could keep track of the timestamp of the last measurement it send for each measurement type.

## REST Web Server in a few simple steps

Here are steps to create a really simple REST server to test the upload:

1. Install json-server globally
     > npm install -g json-server
2. Create a new directory and cd into it
3. Create a file `db.json` that looks like this:
```JSON
{
  "healthData": []
}
```
4. Create a package.json that looks like this:
```Javascript
{  
  "scripts": {
    "start": "json-server --watch db.json"
  }
}
```
5. Run `npm start`
6. Open [localhost:3000/healthData](http://localhost:3000/healthData)
7. Now run the HealthKit app. Assuming you have given the required permissions, entered some attributes and some measurements, click on the "Upload Health Data" button. This should upload the data to the server, where it will be added to the `db.json` file.
8. Refresh the web page and you should see the data.

