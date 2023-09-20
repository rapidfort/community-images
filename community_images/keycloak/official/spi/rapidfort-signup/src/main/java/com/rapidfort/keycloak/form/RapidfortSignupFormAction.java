package com.rapidfort.keycloak.form;

import java.util.List;
import java.util.ArrayList;
import javax.ws.rs.core.MultivaluedMap;

import org.keycloak.Config.Scope;
import org.keycloak.authentication.FormAction;
import org.keycloak.authentication.FormActionFactory;
import org.keycloak.authentication.FormContext;
import org.keycloak.authentication.ValidationContext;
import org.keycloak.events.Errors;
import org.keycloak.forms.login.LoginFormsProvider;
import org.keycloak.models.AuthenticationExecutionModel.Requirement;
import org.keycloak.models.GroupModel;
import org.keycloak.models.KeycloakSession;
import org.keycloak.models.KeycloakSessionFactory;
import org.keycloak.models.RealmModel;
import org.keycloak.models.UserModel;
import org.keycloak.models.utils.FormMessage;
import org.keycloak.provider.ProviderConfigProperty;


public class RapidfortSignupFormAction implements FormAction, FormActionFactory {

	private static final String PROVIDER_ID = "rapidfort-signup-formaction";
	private static Requirement[] REQUIREMENT_CHOICES = { Requirement.REQUIRED, Requirement.DISABLED };
	private static final String DISPLAY_TYPE = "RapidfortSignup";
	private static final String HELP_TEXT = "Rapidfort signup validator";
	
	@Override
	public void close() {
		System.out.println("RapidfortSignupFormAction: close");
		System.out.flush();
	}

	@Override
	public FormAction create(KeycloakSession session) {
		System.out.println("RapidfortSignupFormAction: create");
		System.out.flush();
		return this;
	}

	@Override
	public void init(Scope config) {
		System.out.println("RapidfortSignupFormAction: init");
		System.out.flush();
	}

	@Override
    public void postInit(KeycloakSessionFactory factory) {
		System.out.println("RapidfortSignupFormAction: postInit");
		System.out.flush();
    }

	@Override
	public String getId() {
		System.out.println("RapidfortSignupFormAction: getId");
		System.out.flush();
		return PROVIDER_ID;
	}

	@Override
	public String getDisplayType() {
		System.out.println("RapidfortSignupFormAction: getDisplayType");
		System.out.flush();

		return DISPLAY_TYPE;
	}

	@Override
	public String getReferenceCategory() {
		System.out.println("RapidfortSignupFormAction: getReferenceCategory");
		System.out.flush();

		return null;
	}

	@Override
	public boolean isConfigurable() {
		System.out.println("RapidfortSignupFormAction: isConfigurable");
		System.out.flush();

		return false;
	}

	@Override
	public Requirement[] getRequirementChoices() {
		System.out.println("RapidfortSignupFormAction: getRequirementChoices");
		System.out.flush();

		return REQUIREMENT_CHOICES;
	}

	@Override
	public boolean isUserSetupAllowed() {
		System.out.println("RapidfortSignupFormAction: isUserSetupAllowed");
		System.out.flush();

		return false;
	}

	@Override
	public String getHelpText() {
		System.out.println("RapidfortSignupFormAction: getHelpText");
		System.out.flush();

		return HELP_TEXT;
	}

	@Override
	public List<ProviderConfigProperty> getConfigProperties() {
		System.out.println("RapidfortSignupFormAction: getConfigProperties");
		System.out.flush();

		return null;
	}

	@Override
	public void buildPage(FormContext context, LoginFormsProvider form) {
		System.out.println("RapidfortSignupFormAction: buildPage");
		System.out.flush();

	}
	
	public boolean isBlank(String s) {
        return s == null || s.trim().length() == 0;
	}
	
	@Override
	public void validate(ValidationContext context) {
		System.out.println("RapidfortSignupFormAction: validate");
		System.out.flush();

		MultivaluedMap<String, String> formData = context.getHttpRequest().getDecodedFormParameters();
		List<FormMessage> errors = new ArrayList<>();

		String eventError = Errors.INVALID_REGISTRATION;
		
		if (isBlank(formData.getFirst("user.attributes.organization"))) {
			errors.add(new FormMessage("user.attributes.organization", "Please specify Organization."));
		} 
		else {
			String organization = formData.getFirst("user.attributes.organization");
			List<UserModel> users = context.getSession().users().searchForUserByUserAttribute("organization", organization, context.getRealm());
			for (UserModel user: users) {
				System.out.println("RapidfortSignupFormAction: !!!! validate" + user.getEmail());
			}
		}
		
		if (errors.size() > 0) {
			context.error(eventError);
			context.validationError(formData, errors);
			return;
		} 
		else {
			context.success();
		}
	}

	@Override
	public void success(FormContext context) {
		System.out.println("RapidfortSignupFormAction: success");

	}

	@Override
	public boolean requiresUser() {
		System.out.println("RapidfortSignupFormAction: requiresUser");
		return false;
	}

	@Override
	public boolean configuredFor(KeycloakSession session, RealmModel realm, UserModel user) {
		System.out.println("RapidfortSignupFormAction: configuredFor");
		return false;
	}

	@Override
	public void setRequiredActions(KeycloakSession session, RealmModel realm, UserModel user) {
		System.out.println("RapidfortSignupFormAction: setRequiredActions");
	}
}
