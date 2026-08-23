Homarr allows for the ability to change their CSS, while still working on the same mantine framework. There are a couple things to keep note of while working through this. 

- There is no support for actual custom CSS provided by Homarr
	- If you want to go the custom CSS route you either have to configure yourself or find someone who shared their custom config (like me)
- Homarr uses [https://mantine.dev/](https://mantine.dev/) under the hood. You can change the look & feel of Homarr using custom CSS, that extends or overwrites the styles from Mantine.
- CSS can make your page feel more like your own, but there is a black and white line on what it can and cannot do:
	- Implement new features, widgets or integrations
	- Securely hide elements you don't want users to interact / have permission to
	- Completely revamp the design of the page, only smaller changes are possible
- Homarr does have many pre-defined styles
	- These styles can be reused
	- If reusing a style, include `!important` at the end to override

#### [View my custom CSS](./custom-homepage.css)