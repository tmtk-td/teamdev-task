class TeamsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_team, only: %i[show edit update destroy pass_owner]

  def index
    @teams = Team.all
  end

  def show
    @working_team = @team
    change_keep_team(current_user, @team)
  end

  def new
    @team = Team.new
  end

  def edit
    redirect_to team_url, notice: I18n.t('views.messages.cannot_edit_team_info') unless @team.owner.id == current_user.id
  end

  def create
    @team = Team.new(team_params)
    @team.owner = current_user
    if @team.save
      @team.invite_member(@team.owner)
      redirect_to @team, notice: I18n.t('views.messages.create_team')
    else
      flash.now[:error] = I18n.t('views.messages.failed_to_save_team')
      render :new
    end
  end

  def update
    if @team.update(team_params)
      redirect_to @team, notice: I18n.t('views.messages.update_team')
    else
      flash.now[:error] = I18n.t('views.messages.failed_to_save_team')
      render :edit
    end
  end

  def destroy
    @team.destroy
    redirect_to teams_url, notice: I18n.t('views.messages.delete_team')
  end

  def dashboard
    @team = current_user.keep_team_id ? Team.find(current_user.keep_team_id) : current_user.teams.first
  end

  def pass_owner
    @assign = Assign.find(params[:assign])
    if @team.update(owner_id: @assign.user.id)
      # リーダー権限を移動させ、新しく権限を付与されたユーザーにメールを送信する処理
      PassOwnerMailer.pass_owner_mail(@assign, @team).deliver
      redirect_to team_url, notice: I18n.t('views.messages.assign_to_leader', :team => @team.name)
    else
      # リーダー権限が移動できなかった場合の処理
      redirect_to team_url, notice: I18n.t('views.messages.cannot_assign_to_leader')
    end
  end  

  private

  def set_team
    @team = Team.friendly.find(params[:id])
  end

  def team_params
    params.fetch(:team, {}).permit %i[name icon icon_cache owner_id keep_team_id]
  end
end
