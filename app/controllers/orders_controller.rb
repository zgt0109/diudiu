class OrdersController < ApplicationController
  def index
    @orders = current_user.orders
  end

  def new
    @task = Task.find(params[:task_id])
    @wangwangs = current_user.wangwangs.confirmed

    if current_user.deliver.blank?
      flash[:error] = '接手任务需要有收获地址'
      redirect_to delivers_path
      return
    end
    if @wangwangs.blank?
      flash[:error] = '接手任务前需要绑定旺旺'
      redirect_to wangwangs_path
      return
    end

    if current_user.frozen_amount < @task.price
      flash[:error] = '目前冻结的资金不能接手改任务'
      redirect_to deposits_path
      return
    end

    unless ['checked', 'officialed'].include?(current_user.state)
      flash[:error] = '接手任务前需要进行账户认证'
      redirect_to edit_authenticates_path
      return
    end
  end

  def create
    @task = Task.find(params[:task_id])
    @order = @task.build_order(order_param)
    @order.user = current_user
    if @order.save
      flash[:success] = "接单成功"
      redirect_to orders_path
    else
      render :new
    end
  end

  def reject
    Order.find(params[:id]).destroy
    flash[:success] = '审核操作成功: 拒绝'
    redirect_to my_task_path
  end

  def confirm
    Order.find(params[:id]).confirm!
    flash[:success] = '审核操作成功: 通过'
    redirect_to my_task_path
  end

  private
    def order_param
      params.require(:order).permit(:wangwang_id)
    end
end
