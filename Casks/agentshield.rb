cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2206"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2206/agentshield_0.2.2206_darwin_amd64.tar.gz"
      sha256 "3d4652ae7892e5d41b9db37ab7375dab47a8561b4cc684dd659c283b421b3683"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2206/agentshield_0.2.2206_darwin_arm64.tar.gz"
      sha256 "dd5dbff81e981f9b6ae4d01e6d7f99f326a59722a8f05bca6bd309ac97bad746"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2206/agentshield_0.2.2206_linux_amd64.tar.gz"
      sha256 "650471dce8d0e75f7fa8089f02918aca600dda4ea8180977777d21c50a759916"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2206/agentshield_0.2.2206_linux_arm64.tar.gz"
      sha256 "db76380ff43e8a1f071f020e3a4692d75a7b71f02a05869eb8173b9ccd43f942"
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
