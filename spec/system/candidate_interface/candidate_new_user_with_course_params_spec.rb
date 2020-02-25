require 'rails_helper'

RSpec.describe 'A new candidate arriving from Find with a course and provider code' do
  scenario 'retaining their course selection through the sign up process' do
    given_the_pilot_is_open
    and_the_course_i_selected_only_has_one_site

    when_i_arrive_from_find_to_a_course_that_is_open_on_apply
    and_i_click_apply_on_apply
    when_i_fill_in_the_eligiblity_form_with_yes

    when_i_submit_my_email_address
    and_click_on_the_magic_link
    then_i_should_see_the_course_selection_page
    and_i_should_see_an_account_created_flash_message

    when_i_say_yes
    then_i_should_see_the_courses_review_page
    and_i_should_see_the_course_name_and_code
    and_i_should_see_the_site
    and_my_course_from_find_id_should_be_set_to_nil
    and_my_last_signed_in_at_should_be_now

    given_the_course_i_selected_has_multiple_sites

    when_i_submit_my_email_address
    and_click_on_the_magic_link
    then_i_should_see_the_multi_site_course_selection_page
    and_i_should_see_an_account_created_flash_message

    when_i_say_yes
    then_i_should_see_the_course_choices_site_page
    and_i_see_the_form_to_pick_a_location
    and_my_course_from_find_id_should_be_set_to_nil
    and_my_last_signed_in_at_should_be_now
  end

  def given_the_pilot_is_open
    FeatureFlag.activate('pilot_open')
  end

  def and_the_course_i_selected_only_has_one_site
    @course = create(:course, exposed_in_find: true, open_on_apply: true, name: 'Potions')
    @site = create(:site, provider: @course.provider)
    create(:course_option, site: @site, course: @course, vacancy_status: 'B')
  end

  def given_the_course_i_selected_has_multiple_sites
    @course_with_multiple_sites = create(:course, exposed_in_find: true, open_on_apply: true, name: 'Herbology')
    @site1 = create(:site, provider: @course_with_multiple_sites.provider)
    @site2 = create(:site, provider: @course_with_multiple_sites.provider)
    create(:course_option, site: @site1, course: @course_with_multiple_sites, vacancy_status: 'B')
    create(:course_option, site: @site2, course: @course_with_multiple_sites, vacancy_status: 'B')

    visit candidate_interface_sign_up_path providerCode: @course_with_multiple_sites.provider.code, courseCode: @course_with_multiple_sites.code
  end

  def when_i_arrive_from_find_to_a_course_that_is_open_on_apply
    visit candidate_interface_apply_from_find_path(
      providerCode: @course.provider.code,
      courseCode: @course.code,
    )
  end

  def and_i_click_apply_on_apply
    click_on t('apply_from_find.apply_button')
  end

  def when_i_fill_in_the_eligiblity_form_with_yes
    within_fieldset('Are you a citizen of the UK or the EU?') do
      choose 'Yes'
    end

    within_fieldset('Did you gain all your qualifications at institutions based in the UK?') do
      choose 'Yes'
    end

    click_on 'Continue'
  end

  def when_i_submit_my_email_address
    perform_enqueued_jobs do
      @email = "#{SecureRandom.hex}@example.com"
      fill_in t('authentication.sign_up.email_address.label'), with: @email
      check t('authentication.sign_up.accept_terms_checkbox')
      click_on t('authentication.sign_up.button_continue')
    end
  end

  def and_click_on_the_magic_link
    open_email(@email)
    current_email.find_css('a').first.click
  end

  def then_i_should_see_the_course_selection_page
    expect(page).to have_content('You selected a course')
    expect(page).to have_content(@course.provider.name)
    expect(page).to have_content(@course.name_and_code)
  end

  def then_i_should_see_the_multi_site_course_selection_page
    expect(page).to have_content('You selected a course')
    expect(page).to have_content(@course_with_multiple_sites.provider.name)
    expect(page).to have_content(@course_with_multiple_sites.name_and_code)
  end

  def when_i_say_yes
    choose 'Yes'
    click_on 'Continue'
  end


  def then_i_should_see_the_courses_review_page
    expect(page).to have_current_path(candidate_interface_course_choices_review_path)
  end

  def and_i_should_see_the_course_name_and_code
    expect(page).to have_content "#{@course.name} (#{@course.code})"
  end

  def and_i_should_see_the_site
    expect(page).to have_content @site.name
    expect(page).to have_content @site.address_line1
    expect(page).to have_content @site.address_line2
    expect(page).to have_content @site.address_line3
    expect(page).to have_content @site.address_line4
    expect(page).to have_content @site.postcode
  end

  def and_i_see_the_form_to_pick_a_location
    expect(page).to have_content @site1.name
    expect(page).to have_content @site1.address_line1
    expect(page).to have_content @site1.address_line2
    expect(page).to have_content @site1.address_line3
    expect(page).to have_content @site1.address_line4
    expect(page).to have_content @site1.postcode
    expect(page).to have_content @site2.name
    expect(page).to have_content @site2.address_line1
    expect(page).to have_content @site2.address_line2
    expect(page).to have_content @site2.address_line3
    expect(page).to have_content @site2.address_line4
    expect(page).to have_content @site2.postcode
  end

  def and_my_course_from_find_id_should_be_set_to_nil
    @candidate = Candidate.find_by!(email_address: @email)
    expect(@candidate.course_from_find_id).to eq(nil)
  end

  def then_i_should_see_the_course_choices_site_page
    expect(page).to have_current_path(
      candidate_interface_course_choices_site_path(
        @course_with_multiple_sites.provider.id,
        @course_with_multiple_sites.id,
        :full_time,
      ),
    )
  end

  def and_i_should_see_an_account_created_flash_message
    expect(page).to have_content(t('apply_from_find.account_created_message'))
  end

  def and_my_last_signed_in_at_should_be_now
    expect(@candidate.last_signed_in_at).to be_within(1.second).of(Time.zone.now)
  end
end
