cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1700"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1700/agentshield_0.2.1700_darwin_amd64.tar.gz"
      sha256 "7223327075294c7410d87952ab1e385e901cf401e85deb0b30cf60a958fd91ea"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1700/agentshield_0.2.1700_darwin_arm64.tar.gz"
      sha256 "051d0cec8b2e83326554417b6de7e769de387f01636d5b711169bfcc5ea05a25"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1700/agentshield_0.2.1700_linux_amd64.tar.gz"
      sha256 "231c35c19a6abad40ff12b34143041dad70d289b3b6ec1cc179d87a218a8f272"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1700/agentshield_0.2.1700_linux_arm64.tar.gz"
      sha256 "d5ce7bf76d68794a5c60097394d9f8188db74a3ab7cbfec7225a3dfc616b6d8a"
    end
  end

  # Stop the heartbeat daemon before upgrading so the old binary doesn't keep
  # running as a zombie after brew replaces it.
  preflight do
    if OS.mac?
      plist = File.expand_path("~/Library/LaunchAgents/com.aiagentlens.agentshield.plist")
      if File.exist?(plist)
        system_command "/bin/launchctl", args: ["bootout", "gui/#{Process.uid}/com.aiagentlens.agentshield"], print_stderr: false
        File.delete(plist) if File.exist?(plist)
      end
    end
  end

  postflight do
    if OS.mac?
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentshield"]
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentcompliance"]
    end
  end

  uninstall launchctl: "com.aiagentlens.agentshield",
            delete:    "~/Library/LaunchAgents/com.aiagentlens.agentshield.plist"

  caveats <<~EOS
    Two tools installed:
      agentshield      — Runtime security gateway for AI agents
      agentcompliance  — Local compliance scanner (semgrep-based)

    Quick start:
      agentshield setup
      agentshield login
  EOS
end
