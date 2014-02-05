<p>
    你將需要用OpenStreetMap帳號登入以進行任何編輯，在下面登入或
    to do any editing; do that below or
    <a href="http://www.openstreetmap.org/user/new">開啟一個新的帳號</a>。
    密碼直接傳給OpenStreetMap，<strong><i>Walking Papers</i> 將不會保留你的密碼，</strong>。
</p>
<p>
    <label for="username">電子郵件信箱 或使用者帳號</label>
    <br />
    <input id="username-textfield" name="username" type="text" size="30" />
</p>
<script type="text/javascript">
// <![CDATA[{literal}

    if(readCookie('openstreetmap-username') && document.getElementById('username-textfield'))
        document.getElementById('username-textfield').value = readCookie('openstreetmap-username');

// {/literal}]]>
</script>
<p>
    <label for="password">密碼</label>
    <br />
    <input name="password" type="password" size="30" />
    <br />
    (<a href="http://www.openstreetmap.org/user/forgot-password">Lost your password?</a>)
</p>
<p>
    這個表格將被一個互動性編輯視窗所取代，視窗中會有你的掃瞄圖為背景以當導引。
</p>
