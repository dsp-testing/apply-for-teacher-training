require 'rails_helper'

RSpec.feature 'Organisation permissions' do
  include DfESignInHelpers

  scenario 'Provider user views their organisation permissions page with various permissions' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_can_manage_orgs_for_one_provider
    and_i_cannot_manage_orgs_for_another_provider
    and_i_belong_to_a_provider_with_no_open_courses
    and_i_sign_in_to_the_provider_interface

    when_i_go_to_organisation_settings
    then_i_can_see_the_correct_organisation_permissions_links

    when_i_go_to_organisation_settings
    and_i_click_on_organisation_permissions_for_the_provider_i_can_manage
    then_i_can_see_the_permissions_with_change_links

    when_i_go_to_organisation_settings
    and_i_click_on_organisation_permissions_for_the_provider_i_cannot_manage
    then_i_can_see_the_permissions_that_have_been_set_up_without_change_links
    and_i_can_see_non_set_up_permissions
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
  end

  def and_i_can_manage_orgs_for_one_provider
    @manage_orgs_provider = create(:provider, code: 'ABC')
    @provider_user = create(
      :provider_user,
      :with_manage_organisations,
      providers: [@manage_orgs_provider],
      dfe_sign_in_uid: 'DFE_SIGN_IN_UID',
      email_address: 'email@provider.ac.uk',
    )

    relationship = create(:provider_relationship_permissions, training_provider: @manage_orgs_provider)
    @manage_orgs_partner = relationship.ratifying_provider
    create_open_course_for_relationship(relationship)
  end

  def and_i_cannot_manage_orgs_for_another_provider
    @read_only_provider = create(:provider, code: 'DEF')
    create(:provider_permissions, provider_user: @provider_user, provider: @read_only_provider)

    set_up_relationship = create(:provider_relationship_permissions, ratifying_provider: @read_only_provider)
    create_open_course_for_relationship(set_up_relationship)
    @set_up_read_only_partner = set_up_relationship.training_provider

    not_set_up_relationship = create(:provider_relationship_permissions, :not_set_up_yet, ratifying_provider: @read_only_provider)
    create_open_course_for_relationship(not_set_up_relationship)
    @not_set_up_read_only_partner = not_set_up_relationship.training_provider
  end

  def create_open_course_for_relationship(relationship)
    create(:course, :open_on_apply, provider: relationship.training_provider, accredited_provider: relationship.ratifying_provider)
  end

  def and_i_belong_to_a_provider_with_no_open_courses
    @no_open_courses_provider = create(:provider, code: 'GHI')
    create(:provider_permissions, provider_user: @provider_user, provider: @no_open_courses_provider)

    create(:provider_relationship_permissions, training_provider: @no_open_courses_provider)
  end

  def when_i_go_to_organisation_settings
    click_link t('page_titles.provider.organisation_settings'), match: :first
  end

  def then_i_can_see_the_correct_organisation_permissions_links
    expect(page).to have_link("Organisation permissions #{@manage_orgs_provider.name}")
    expect(page).to have_link("Organisation permissions #{@read_only_provider.name}")
    expect(page).not_to have_link("Organisation permissions #{@no_open_courses_provider.name}")
  end

  def and_i_click_on_organisation_permissions_for_the_provider_i_can_manage
    click_link "Organisation permissions #{@manage_orgs_provider.name}"
  end

  def then_i_can_see_the_permissions_with_change_links
    expect(page).to have_css('h2', text: "#{@manage_orgs_provider.name} and #{@manage_orgs_partner.name}")
    expect(page).to have_link("Change #{@manage_orgs_provider.name} and #{@manage_orgs_partner.name}")
  end

  def and_i_click_on_organisation_permissions_for_the_provider_i_cannot_manage
    click_link "Organisation permissions #{@read_only_provider.name}"
  end

  def then_i_can_see_the_permissions_that_have_been_set_up_without_change_links
    expect(page).to have_css('h2', text: "#{@read_only_provider.name} and #{@set_up_read_only_partner.name}")
    expect(page).not_to have_css('.app-summary-card__actions > a')
  end

  def and_i_can_see_non_set_up_permissions
    expect(page).to have_css('h2', text: "#{@read_only_provider.name} and #{@not_set_up_read_only_partner.name}")
    expect(page).to have_css('.govuk-summary-list__value', text: 'Neither organisation can do this')
  end
end
