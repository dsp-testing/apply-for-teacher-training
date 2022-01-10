module SupportInterface
  class DuplicateMatchesController < SupportInterfaceController
    before_action :check_feature_flag

    def index
      @matches = FraudMatch.where(
        recruitment_cycle_year: RecruitmentCycle.current_year,
        resolved: ActiveModel::Type::Boolean.new.cast(params[:resolved]) || false,
      ).order(:created_at)
    end

    def show
      @match = FraudMatch.find(params[:id])
    end

    def update
      @match = FraudMatch.find(params[:id])
      @match.update(
        resolved: ActiveModel::Type::Boolean.new.cast(params[:resolved])
      )
      redirect_to support_interface_duplicate_match_path(@match)
    end

  private

    def check_feature_flag
      render_404 and return unless FeatureFlag.active?(:duplicate_matching)
    end
  end
end
