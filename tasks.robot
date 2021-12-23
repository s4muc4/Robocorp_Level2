*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.
Library           RPA.Browser.Selenium    auto_close=${FALSE}
Library           RPA.HTTP
Library           RPA.Tables
Library           RPA.PDF
Library           OperatingSystem
Library           RPA.Archive
Library           RPA.Dialogs
Library           RPA.Robocorp.Vault
Library           Dialogs

*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    ${url}=    Get URL RobotSpareBin Industries Inc from vault
    ${result_form}=    Input form Dialog to get URL of download of CSV
    Log    Your Email is: ${result_form.email}
    Log    CSV URL: ${result_form.url}
    Open the robot order website    ${url}
    Download the CSV file    ${result_form.url}
    ${orders}=    Get orders
    FOR    ${row}    IN    @{orders}
        Log    Item number ${row}
        Close the annoyng modal
        Fill the form    ${row}
        Preview the robot
        Submit the order
        Store the receipt as a PDF file    ${row}[Order number]
        Take a screenshot of the robot    ${row}[Order number]
        Embed the robot screenshot to the receipt PDF file    ${row}[Order number]
        Go to order another robot
        Delete Images of Robots    ${row}[Order number]
    END
    Close Site
    Create a ZIP file of the receipts
    Remove folder of PDFs

*** Keywords ***
Open the robot order website
    [Arguments]    ${url}
    Open Available Browser    ${url}
    Wait Until Element Is Visible    //*[@id="root"]/header/div/ul/li[2]/a
    Click Element    //*[@id="root"]/header/div/ul/li[2]/a

Download the CSV file
    [Arguments]    ${URL_Download}
    Download    ${URL_Download}    overwrite=True

Close the annoyng modal
    Wait Until Element Is Visible    //*[@id="root"]/div/div[2]/div/div/div/div/div/button[1]
    Click Element    //*[@id="root"]/div/div[2]/div/div/div/div/div/button[1]

Get orders
    ${orders}=    Read table from CSV    orders.csv
    [Return]    ${orders}

Fill the form
    [Arguments]    ${row}
    Select From List By Index    //*[@id="head"]    ${row}[Head]
    Click Element    //*[@id="id-body-${row}[Body]"]
    Input Text    //*[@placeholder="Enter the part number for the legs"]    ${row}[Legs]
    Input Text    //*[@id="address"]    ${row}[Address]

Preview the robot
    Click Button    id:preview

Submit the order
    Click Button    id:order
    ${error}=    Get Element Count    //*[@class="alert alert-danger"]
    Log    ${error} erros!
    IF    ${error} > 0
        Log    Erro apareceu, clicano novamente em preview
        Wait Until Element Is Visible    id:order
        Click Button    id:order
    END
    ${error}=    Get Element Count    //*[@class="alert alert-danger"]
    Log    ${error} erros!
    IF    ${error} > 0
        Log    Erro apareceu, clicano novamente em preview
        Wait Until Element Is Visible    id:order
        Click Button    id:order
    END
    ${error}=    Get Element Count    //*[@class="alert alert-danger"]
    Log    ${error} erros!
    IF    ${error} > 0
        Log    Erro apareceu, clicano novamente em preview
        Wait Until Element Is Visible    id:order
        Click Button    id:order
    END
    ${error}=    Get Element Count    //*[@class="alert alert-danger"]
    Log    ${error} erros!
    IF    ${error} > 0
        Log    Erro apareceu, clicano novamente em preview
        Wait Until Element Is Visible    id:order
        Click Button    id:order
    END

Store the receipt as a PDF file
    [Arguments]    ${ordernumber}
    Wait Until Element Is Visible    id:receipt
    ${receipt}=    Get Text    id:receipt
    Html To Pdf    ${receipt}    ${OUTPUT_DIR}${/}generated_files${/}sales_results_${ordernumber}.pdf

Take a screenshot of the robot
    [Arguments]    ${ordernumber}
    Wait Until Element Is Visible    id:robot-preview-image
    Screenshot    id:robot-preview-image    ${OUTPUT_DIR}${/}generated_files${/}robot_generated_${ordernumber}.png

Go to order another robot
    Click Button    id:order-another

Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${ordernumber}
    ${files}=    Create List
    ...    ${OUTPUT_DIR}${/}generated_files${/}robot_generated_${ordernumber}.png
    Add Files To Pdf    ${files}    ${OUTPUT_DIR}${/}generated_files${/}sales_results_${ordernumber}.pdf    append=True

Close Site
    Close Browser

Delete Images of Robots
    [Arguments]    ${ordernumber}
    Remove File    ${OUTPUT_DIR}${/}generated_files${/}robot_generated_${ordernumber}.png

Create a ZIP file of the receipts
    Archive Folder With Zip    ${OUTPUT_DIR}${/}generated_files    Robots_PDF.zip

Remove folder of PDFs
    Remove Directory    ${OUTPUT_DIR}${/}generated_files    recursive= True

Input form Dialog to get URL of download of CSV
    Add heading    Send URL of orders (csv)
    Add text input    email    label=E-mail adress
    Add text input    url
    ...    label=URL of CSV
    ...    placeholder=insert here the URL of download of CSV
    ${result}=    Run dialog
    [Return]    ${result}

Get URL RobotSpareBin Industries Inc from vault
    ${secret}=    Get Secret    urls
    Log    url: ${secret}[url_sparebin]
    [Return]    ${secret}[url_sparebin]
