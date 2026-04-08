cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.506"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.506/agentshield_0.2.506_darwin_amd64.tar.gz"
      sha256 "c10815738e13c4e7aacd8e7baf5e516c9de54b629234cc62a151ea08659e87e9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.506/agentshield_0.2.506_darwin_arm64.tar.gz"
      sha256 "61e92eddb66945c4245190baa9504dbad56946eb180725550b8c3c274efc05ea"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.506/agentshield_0.2.506_linux_amd64.tar.gz"
      sha256 "eccce5b2542472ffb393c7a36ecefb506f0a8f95e344ef305df82c21fabc64ec"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.506/agentshield_0.2.506_linux_arm64.tar.gz"
      sha256 "2185f6795e0d1c2795dc546ca4527629bb4f81712aa3799b9b44b240f0cd01e7"
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
