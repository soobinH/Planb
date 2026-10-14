document.addEventListener("DOMContentLoaded", function() {
	console.log("signup.js 정상 로드됨");
	var form = document.getElementById("signupForm");

	if (!form) {
		return;
	}


	/* ============================================================
	   기본 입력 요소
	   ============================================================ */

	var loginId =
		document.getElementById("loginId");

	var password =
		document.getElementById("password");

	var passwordConfirm =
		document.getElementById("passwordConfirm");

	var nameInput =
		document.getElementById("name");

	var nickname =
		document.getElementById("nickname");

	var email =
		document.getElementById("email");

	var phone =
		document.getElementById("phone");


	var postcode =
		document.getElementById("postcode");

	var address =
		document.getElementById("address");

	var addressDetail =
		document.getElementById("addressDetail");


	var profileImage =
		document.getElementById("profileImage");

	var profilePreview =
		document.getElementById("profilePreview");


	var bio =
		document.getElementById("bio");

	var bioCounter =
		document.getElementById("bioCounter");


	var signupError =
		document.getElementById("signupError");

	var postcodeButton =
		document.getElementById("postcodeButton");


	/* ============================================================
	   중복 확인
	   ============================================================ */

	var loginIdCheckButton =
		document.getElementById(
			"loginIdCheckButton"
		);

	var nicknameCheckButton =
		document.getElementById(
			"nicknameCheckButton"
		);


	var loginIdCheckMessage =
		document.getElementById(
			"loginIdCheckMessage"
		);

	var nicknameCheckMessage =
		document.getElementById(
			"nicknameCheckMessage"
		);


	/* ============================================================
	   이메일 인증
	   ============================================================ */

	var sendEmailCodeButton =
		document.getElementById(
			"sendEmailCodeButton"
		);

	var verifyEmailCodeButton =
		document.getElementById(
			"verifyEmailCodeButton"
		);


	var emailVerificationArea =
		document.getElementById(
			"emailVerificationArea"
		);

	var emailVerificationCode =
		document.getElementById(
			"emailVerificationCode"
		);


	var emailSendMessage =
		document.getElementById(
			"emailSendMessage"
		);

	var emailVerificationMessage =
		document.getElementById(
			"emailVerificationMessage"
		);


	/* ============================================================
	   Context Path

	   form action:
	   /Planb/auth/signup

	   결과:
	   /Planb
	   ============================================================ */

	var formAction =
		form.getAttribute("action") || "";


	var contextPath =
		formAction.replace(
			/\/auth\/signup$/,
			""
		);


	/* ============================================================
	   중복확인 / 이메일 인증 상태
	   ============================================================ */

	var loginIdChecked = false;

	var checkedLoginId = "";


	var nicknameChecked = false;

	var checkedNickname = "";


	var emailVerified = false;

	var verifiedEmail = "";


	/* ============================================================
	   에러 처리
	   ============================================================ */

	function showError(
		input,
		message
	) {

		if (!input) {
			return;
		}


		input.classList.add(
			"is-invalid"
		);


		var error =
			document.querySelector(
				'[data-error-for="'
				+ input.id
				+ '"]'
			);


		if (error) {

			error.textContent =
				message;

		}

	}


	function clearError(
		input
	) {

		if (!input) {
			return;
		}


		input.classList.remove(
			"is-invalid"
		);


		var error =
			document.querySelector(
				'[data-error-for="'
				+ input.id
				+ '"]'
			);


		if (error) {

			error.textContent = "";

		}

	}


	function clearAllErrors() {

		var invalidElements =
			document.querySelectorAll(
				".is-invalid"
			);


		var i;


		for (
			i = 0;
			i < invalidElements.length;
			i++
		) {

			invalidElements[i]
				.classList
				.remove(
					"is-invalid"
				);

		}


		var errors =
			document.querySelectorAll(
				".field-error"
			);


		for (
			i = 0;
			i < errors.length;
			i++
		) {

			errors[i].textContent = "";

		}


		if (signupError) {

			signupError.hidden =
				true;

		}

	}


	/* ============================================================
	   안내 메시지
	   ============================================================ */

	function setMessage(
		element,
		message,
		success
	) {

		if (!element) {
			return;
		}


		element.textContent =
			message || "";


		if (!message) {

			element.style.color =
				"";

			return;

		}


		if (success) {

			element.style.color =
				"#2f8f55";

		} else {

			element.style.color =
				"#c73d49";

		}

	}


	/* ============================================================
	   버튼 로딩 처리
	   ============================================================ */

	function setButtonLoading(
		button,
		loading,
		loadingText
	) {

		if (!button) {
			return;
		}


		if (loading) {


			if (
				!button.getAttribute(
					"data-original-text"
				)
			) {

				button.setAttribute(
					"data-original-text",
					button
						.textContent
						.trim()
				);

			}


			button.disabled = true;


			button.textContent =
				loadingText
				|| "처리 중...";


		} else {


			var original =
				button.getAttribute(
					"data-original-text"
				);


			button.disabled =
				false;


			if (original) {

				button.textContent =
					original;

			}

		}

	}


	/* ============================================================
	   AJAX JSON 요청
	   ============================================================ */

	function requestJson(
		method,
		url,
		body,
		callback
	) {

		var xhr =
			new XMLHttpRequest();


		xhr.open(
			method,
			url,
			true
		);


		xhr.setRequestHeader(
			"Accept",
			"application/json"
		);


		if (
			method === "POST"
			&& typeof body === "string"
		) {

			xhr.setRequestHeader(
				"Content-Type",
				"application/x-www-form-urlencoded; charset=UTF-8"
			);

		}


		xhr.onreadystatechange =
			function() {


				if (
					xhr.readyState !== 4
				) {

					return;

				}


				var data = null;


				try {

					data =
						JSON.parse(
							xhr.responseText
						);

				} catch (e) {

					data = null;

				}


				if (
					xhr.status >= 200
					&& xhr.status < 300
				) {


					callback(
						null,
						data
					);


				} else {


					callback(
						new Error(
							"요청 처리 중 오류가 발생했습니다."
						),
						data
					);


				}

			};


		xhr.onerror =
			function() {


				callback(
					new Error(
						"서버와 통신할 수 없습니다."
					),
					null
				);


			};


		xhr.send(
			body || null
		);

	}


	/* ============================================================
	   Validation 함수
	   ============================================================ */

	function isValidLoginId(
		value
	) {

		return /^[A-Za-z0-9_]{4,20}$/
			.test(value);

	}


	function isValidPassword(
		value
	) {

		return /^(?=.*[A-Za-z])(?=.*\d).{8,}$/
			.test(value);

	}


	function isValidPhone(
		value
	) {

		return /^01[016789]-\d{3,4}-\d{4}$/
			.test(value);

	}


	/* ============================================================
	   공통 중복검사
	   ============================================================ */

	function checkDuplicate(
		type,
		value,
		button,
		callback
	) {


		var url =

			contextPath

			+ "/auth/check-duplicate"

			+ "?type="

			+ encodeURIComponent(
				type
			)

			+ "&value="

			+ encodeURIComponent(
				value
			);


		setButtonLoading(
			button,
			true,
			"확인 중..."
		);


		requestJson(

			"GET",

			url,

			null,

			function(
				error,
				data
			) {


				setButtonLoading(
					button,
					false
				);


				if (error) {


					callback(

						false,

						"중복확인 중 오류가 발생했습니다."

					);


					return;

				}


				if (
					!data
					|| typeof data.available
					=== "undefined"
				) {


					callback(

						false,

						"서버 응답을 확인할 수 없습니다."

					);


					return;

				}


				callback(

					data.available
					=== true,

					data.message
					|| ""

				);


			}

		);

	}


	/* ============================================================
	   아이디 중복확인
	   ============================================================ */

	if (
		loginIdCheckButton
	) {


		loginIdCheckButton
			.addEventListener(
				"click",
				function() {
					console.log("아이디 중복확인 클릭됨");

					var value =
						loginId
							.value
							.trim();


					clearError(
						loginId
					);


					setMessage(
						loginIdCheckMessage,
						"",
						false
					);


					loginIdChecked =
						false;


					checkedLoginId =
						"";


					if (!value) {


						showError(
							loginId,
							"아이디를 입력해주세요."
						);


						loginId.focus();


						return;

					}


					if (
						!isValidLoginId(
							value
						)
					) {


						showError(

							loginId,

							"아이디는 영문, 숫자, 밑줄(_)을 사용하여 4~20자로 입력해주세요."

						);


						loginId.focus();


						return;

					}


					checkDuplicate(

						"loginId",

						value,

						loginIdCheckButton,

						function(
							available,
							message
						) {


							if (
								available
							) {


								loginIdChecked =
									true;


								checkedLoginId =
									value;


								setMessage(

									loginIdCheckMessage,

									message
									|| "사용 가능한 아이디입니다.",

									true

								);


							} else {


								loginIdChecked =
									false;


								checkedLoginId =
									"";


								setMessage(

									loginIdCheckMessage,

									message
									|| "이미 사용 중인 아이디입니다.",

									false

								);


								loginId.focus();


							}


						}

					);


				}
			);

	}


	/* 아이디 변경 시 중복확인 초기화 */
	loginId.addEventListener(
		"input",
		function() {


			loginIdChecked =
				false;


			checkedLoginId =
				"";


			setMessage(
				loginIdCheckMessage,
				"",
				false
			);


			clearError(
				loginId
			);


		}
	);


	/* ============================================================
	   닉네임 중복확인
	   ============================================================ */

	if (
		nicknameCheckButton
	) {


		nicknameCheckButton
			.addEventListener(
				"click",
				function() {


					var value =
						nickname
							.value
							.trim();


					clearError(
						nickname
					);


					setMessage(
						nicknameCheckMessage,
						"",
						false
					);


					nicknameChecked =
						false;


					checkedNickname =
						"";


					if (!value) {


						showError(
							nickname,
							"닉네임을 입력해주세요."
						);


						nickname.focus();


						return;

					}


					if (
						value.length < 2
					) {


						showError(
							nickname,
							"닉네임은 2자 이상 입력해주세요."
						);


						nickname.focus();


						return;

					}


					checkDuplicate(

						"nickname",

						value,

						nicknameCheckButton,

						function(
							available,
							message
						) {


							if (
								available
							) {


								nicknameChecked =
									true;


								checkedNickname =
									value;


								setMessage(

									nicknameCheckMessage,

									message
									|| "사용 가능한 닉네임입니다.",

									true

								);


							} else {


								nicknameChecked =
									false;


								checkedNickname =
									"";


								setMessage(

									nicknameCheckMessage,

									message
									|| "이미 사용 중인 닉네임입니다.",

									false

								);


								nickname.focus();


							}


						}

					);


				}
			);

	}


	/* 닉네임 변경 시 중복확인 초기화 */
	nickname.addEventListener(
		"input",
		function() {


			nicknameChecked =
				false;


			checkedNickname =
				"";


			setMessage(
				nicknameCheckMessage,
				"",
				false
			);


			clearError(
				nickname
			);


		}
	);


	/* ============================================================
	   이메일 인증 상태 초기화
	   ============================================================ */

	function resetEmailVerification() {


		emailVerified =
			false;


		verifiedEmail =
			"";


		if (
			emailVerificationArea
		) {

			emailVerificationArea.hidden =
				true;

		}


		if (
			emailVerificationCode
		) {

			emailVerificationCode.value =
				"";


			emailVerificationCode.readOnly =
				false;

		}


		if (
			verifyEmailCodeButton
		) {

			verifyEmailCodeButton.disabled =
				false;


			verifyEmailCodeButton.textContent =
				"인증 확인";

		}


		setMessage(
			emailSendMessage,
			"",
			false
		);


		setMessage(
			emailVerificationMessage,
			"",
			false
		);


	}


	/* 이메일 변경 시 인증 초기화 */
	email.addEventListener(
		"input",
		function() {


			clearError(
				email
			);


			resetEmailVerification();


		}
	);


	/* ============================================================
	   이메일 인증번호 발송
	   ============================================================ */

	if (
		sendEmailCodeButton
	) {


		sendEmailCodeButton
			.addEventListener(
				"click",
				function() {


					var emailValue =
						email
							.value
							.trim();


					clearError(
						email
					);


					resetEmailVerification();


					if (
						!emailValue
					) {


						showError(
							email,
							"이메일을 입력해주세요."
						);


						email.focus();


						return;

					}


					if (
						!email.validity.valid
					) {


						showError(
							email,
							"올바른 이메일 형식으로 입력해주세요."
						);


						email.focus();


						return;

					}


					/* 이메일 중복확인 */
					setButtonLoading(

						sendEmailCodeButton,

						true,

						"확인 중..."

					);


					requestJson(

						"GET",

						contextPath

						+ "/auth/check-duplicate"

						+ "?type=email"

						+ "&value="

						+ encodeURIComponent(
							emailValue
						),

						null,

						function(
							duplicateError,
							duplicateData
						) {


							if (
								duplicateError
							) {


								setButtonLoading(
									sendEmailCodeButton,
									false
								);


								setMessage(

									emailSendMessage,

									"이메일 중복확인 중 오류가 발생했습니다.",

									false

								);


								return;

							}


							if (
								!duplicateData
								|| duplicateData.available
								!== true
							) {


								setButtonLoading(
									sendEmailCodeButton,
									false
								);


								setMessage(

									emailSendMessage,

									duplicateData
										&& duplicateData.message

										? duplicateData.message

										: "이미 가입된 이메일입니다.",

									false

								);


								email.focus();


								return;

							}


							/* ===============================
							   인증번호 발송
							   =============================== */

							setButtonLoading(

								sendEmailCodeButton,

								true,

								"발송 중..."

							);


							requestJson(

								"POST",

								contextPath
								+ "/auth/emailSend",

								"email="
								+ encodeURIComponent(
									emailValue
								),

								function(
									sendError,
									sendData
								) {


									setButtonLoading(

										sendEmailCodeButton,

										false

									);


									if (
										sendError
										|| !sendData
										|| sendData.success
										!== true
									) {


										setMessage(

											emailSendMessage,

											sendData
												&& sendData.message

												? sendData.message

												: "인증번호 발송에 실패했습니다.",

											false

										);


										return;

									}


									/* 인증번호 입력 영역 표시 */
									if (
										emailVerificationArea
									) {

										emailVerificationArea.hidden =
											false;

									}


									setMessage(

										emailSendMessage,

										sendData.message
										|| "인증번호를 발송했습니다. 이메일을 확인해주세요.",

										true

									);


									if (
										emailVerificationCode
									) {

										emailVerificationCode.focus();

									}


								}

							);


						}

					);


				}
			);

	}


	/* ============================================================
	   이메일 인증번호 확인
	   ============================================================ */

	if (
		verifyEmailCodeButton
	) {


		verifyEmailCodeButton
			.addEventListener(
				"click",
				function() {


					var emailValue =
						email
							.value
							.trim();


					var code =

						emailVerificationCode

							? emailVerificationCode
								.value
								.trim()

							: "";


					emailVerified =
						false;


					verifiedEmail =
						"";


					setMessage(
						emailVerificationMessage,
						"",
						false
					);


					if (!code) {


						setMessage(

							emailVerificationMessage,

							"인증번호를 입력해주세요.",

							false

						);


						if (
							emailVerificationCode
						) {

							emailVerificationCode.focus();

						}


						return;

					}


					if (
						!/^\d{6}$/.test(
							code
						)
					) {


						setMessage(

							emailVerificationMessage,

							"6자리 인증번호를 입력해주세요.",

							false

						);


						if (
							emailVerificationCode
						) {

							emailVerificationCode.focus();

						}


						return;

					}


					setButtonLoading(

						verifyEmailCodeButton,

						true,

						"확인 중..."

					);


					var body =

						"email="

						+ encodeURIComponent(
							emailValue
						)

						+ "&code="

						+ encodeURIComponent(
							code
						);


					requestJson(

						"POST",

						contextPath
						+ "/auth/emailVerify",

						body,

						function(
							verifyError,
							verifyData
						) {


							setButtonLoading(

								verifyEmailCodeButton,

								false

							);


							if (
								verifyError
								|| !verifyData
								|| verifyData.success
								!== true
							) {


								setMessage(

									emailVerificationMessage,

									verifyData
										&& verifyData.message

										? verifyData.message

										: "인증번호가 올바르지 않습니다.",

									false

								);


								return;

							}


							emailVerified =
								true;


							verifiedEmail =
								emailValue;


							setMessage(

								emailVerificationMessage,

								verifyData.message
								|| "이메일 인증이 완료되었습니다.",

								true

							);


							/* 인증 완료 후 이메일 수정 방지 */
							email.readOnly =
								true;


							if (
								sendEmailCodeButton
							) {

								sendEmailCodeButton.disabled =
									true;


								sendEmailCodeButton.textContent =
									"인증완료";

							}


							if (
								emailVerificationCode
							) {

								emailVerificationCode.readOnly =
									true;

							}


							verifyEmailCodeButton.disabled =
								true;


							verifyEmailCodeButton.textContent =
								"인증완료";


						}

					);


				}
			);

	}


	/* ============================================================
	   전화번호 자동 포맷
	   ============================================================ */

	phone.addEventListener(
		"input",
		function() {


			var value =
				this.value.replace(
					/[^0-9]/g,
					""
				);


			if (
				value.length > 11
			) {

				value =
					value.substring(
						0,
						11
					);

			}


			if (
				value.length < 4
			) {


				this.value =
					value;


			} else if (
				value.length < 8
			) {


				this.value =

					value.substring(
						0,
						3
					)

					+ "-"

					+ value.substring(
						3
					);


			} else {


				this.value =

					value.substring(
						0,
						3
					)

					+ "-"

					+ value.substring(
						3,
						7
					)

					+ "-"

					+ value.substring(
						7,
						11
					);


			}

		}
	);


	/* ============================================================
	   소개글 글자수
	   ============================================================ */

	if (
		bio
		&& bioCounter
	) {


		bio.addEventListener(
			"input",
			function() {


				bioCounter.textContent =

					this.value.length

					+ " / 50";


			}
		);

	}


	/* ============================================================
	   프로필 이미지 미리보기
	   ============================================================ */

	if (
		profileImage
		&& profilePreview
	) {


		profileImage.addEventListener(
			"change",
			function() {


				clearError(
					profileImage
				);


				var file =

					this.files
						&& this.files.length > 0

						? this.files[0]

						: null;


				if (!file) {


					profilePreview.innerHTML =
						"<span>사진</span>";


					return;

				}


				var allowedTypes = [

					"image/jpeg",

					"image/png",

					"image/webp"

				];


				if (
					allowedTypes
						.indexOf(
							file.type
						)
					=== -1
				) {


					showError(

						profileImage,

						"JPG, PNG, WEBP 이미지 파일만 사용할 수 있습니다."

					);


					this.value = "";


					profilePreview.innerHTML =
						"<span>사진</span>";


					return;

				}


				var maxFileSize =

					5
					* 1024
					* 1024;


				if (
					file.size
					> maxFileSize
				) {


					showError(

						profileImage,

						"프로필 이미지는 5MB 이하만 등록할 수 있습니다."

					);


					this.value =
						"";


					profilePreview.innerHTML =
						"<span>사진</span>";


					return;

				}


				var reader =
					new FileReader();


				reader.onload =
					function(
						event
					) {


						profilePreview.innerHTML =

							'<img src="'

							+ event
								.target
								.result

							+ '" alt="프로필 이미지 미리보기">';


					};


				reader.readAsDataURL(
					file
				);


			}
		);

	}


	/* ============================================================
	   카카오 주소 검색
	   ============================================================ */

	if (
		postcodeButton
	) {


		postcodeButton.addEventListener(
			"click",
			function() {


				if (
					typeof daum
					=== "undefined"

					|| typeof daum.Postcode
					=== "undefined"
				) {


					alert(

						"주소 검색 서비스를 불러오지 못했습니다.\n"

						+ "잠시 후 다시 시도해주세요."

					);


					return;

				}


				new daum.Postcode({


					oncomplete:
						function(
							data
						) {


							var selectedAddress =
								"";


							if (
								data.userSelectedType
								=== "R"
							) {


								selectedAddress =
									data.roadAddress;


							} else {


								selectedAddress =
									data.jibunAddress;


							}


							postcode.value =
								data.zonecode;


							address.value =
								selectedAddress;


							clearError(
								postcode
							);


							clearError(
								address
							);


							if (
								addressDetail
							) {


								addressDetail.focus();


							}


						}


				}).open();


			}
		);

	}


	/* ============================================================
	   입력 중 에러 해제
	   ============================================================ */

	var inputs =
		form.querySelectorAll(
			"input, textarea"
		);


	var inputIndex;


	for (
		inputIndex = 0;
		inputIndex < inputs.length;
		inputIndex++
	) {


		inputs[inputIndex]
			.addEventListener(
				"input",
				function() {


					clearError(
						this
					);


				}
			);


	}


	/* ============================================================
	   회원가입 Submit
	   ============================================================ */

	form.addEventListener(
		"submit",
		function(
			event
		) {


			clearAllErrors();


			var valid =
				true;


			/* =====================================================
			   아이디
			   ===================================================== */

			var loginIdValue =
				loginId
					.value
					.trim();


			if (
				!loginIdValue
			) {


				showError(

					loginId,

					"아이디를 입력해주세요."

				);


				valid =
					false;


			} else if (
				!isValidLoginId(
					loginIdValue
				)
			) {


				showError(

					loginId,

					"아이디는 영문, 숫자, 밑줄(_)을 사용하여 4~20자로 입력해주세요."

				);


				valid =
					false;


			} else if (
				!loginIdChecked

				|| checkedLoginId
				!== loginIdValue
			) {


				showError(

					loginId,

					"아이디 중복확인을 해주세요."

				);


				valid =
					false;


			}


			/* =====================================================
			   비밀번호
			   ===================================================== */

			if (
				!password.value
			) {


				showError(

					password,

					"비밀번호를 입력해주세요."

				);


				valid =
					false;


			} else if (
				!isValidPassword(
					password.value
				)
			) {


				showError(

					password,

					"비밀번호는 영문과 숫자를 포함하여 8자 이상 입력해주세요."

				);


				valid =
					false;


			}


			/* =====================================================
			   비밀번호 확인
			   ===================================================== */

			if (
				!passwordConfirm.value
			) {


				showError(

					passwordConfirm,

					"비밀번호 확인을 입력해주세요."

				);


				valid =
					false;


			} else if (
				password.value
				!== passwordConfirm.value
			) {


				showError(

					passwordConfirm,

					"비밀번호가 일치하지 않습니다."

				);


				valid =
					false;


			}


			/* =====================================================
			   이름
			   ===================================================== */

			if (
				!nameInput
					.value
					.trim()
			) {


				showError(

					nameInput,

					"이름을 입력해주세요."

				);


				valid =
					false;


			}


			/* =====================================================
			   닉네임
			   ===================================================== */

			var nicknameValue =
				nickname
					.value
					.trim();


			if (
				!nicknameValue
			) {


				showError(

					nickname,

					"닉네임을 입력해주세요."

				);


				valid =
					false;


			} else if (
				nicknameValue.length
				< 2
			) {


				showError(

					nickname,

					"닉네임은 2자 이상 입력해주세요."

				);


				valid =
					false;


			} else if (
				!nicknameChecked

				|| checkedNickname
				!== nicknameValue
			) {


				showError(

					nickname,

					"닉네임 중복확인을 해주세요."

				);


				valid =
					false;


			}


			/* =====================================================
			   이메일
			   ===================================================== */

			var emailValue =
				email
					.value
					.trim();


			if (
				!emailValue
			) {


				showError(

					email,

					"이메일을 입력해주세요."

				);


				valid =
					false;


			} else if (
				!email.validity.valid
			) {


				showError(

					email,

					"올바른 이메일 형식으로 입력해주세요."

				);


				valid =
					false;


			} else if (
				!emailVerified

				|| verifiedEmail
				!== emailValue
			) {


				showError(

					email,

					"이메일 인증을 완료해주세요."

				);


				valid =
					false;


			}


			/* =====================================================
			   전화번호
			   ===================================================== */

			if (
				!phone
					.value
					.trim()
			) {


				showError(

					phone,

					"전화번호를 입력해주세요."

				);


				valid =
					false;


			} else if (
				!isValidPhone(
					phone
						.value
						.trim()
				)
			) {


				showError(

					phone,

					"올바른 전화번호를 입력해주세요."

				);


				valid =
					false;


			}


			/* =====================================================
			   우편번호
			   ===================================================== */

			if (
				!postcode
					.value
					.trim()
			) {


				showError(

					postcode,

					"우편번호를 입력해주세요."

				);


				valid =
					false;


			}


			/* =====================================================
			   주소
			   ===================================================== */

			if (
				!address
					.value
					.trim()
			) {


				showError(

					address,

					"주소를 입력해주세요."

				);


				valid =
					false;


			}


			/* =====================================================
			   Validation 실패
			   ===================================================== */

			if (
				!valid
			) {


				event.preventDefault();


				if (
					signupError
				) {


					signupError.hidden =
						false;


				}


				var firstInvalid =
					form.querySelector(
						".is-invalid"
					);


				if (
					firstInvalid
				) {


					firstInvalid.focus();


					if (
						typeof firstInvalid.scrollIntoView
						=== "function"
					) {


						firstInvalid.scrollIntoView({


							behavior:
								"smooth",


							block:
								"center"


						});


					}


				}


			}


		}
	);


});