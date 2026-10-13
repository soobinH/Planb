package config;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

import util.firebase.FirebaseAccessToken;

@WebListener
public class FirebaseInitializer implements ServletContextListener {

	@Override
	public void contextInitialized(ServletContextEvent event) {
		try {
			FirebaseAccessToken.getAccessToken();

			event.getServletContext().log("Firebase 서버 인증 완료");

		} catch (Exception e) {
			event.getServletContext().log("Firebase 서버 인증 실패", e);
		}
	}
}