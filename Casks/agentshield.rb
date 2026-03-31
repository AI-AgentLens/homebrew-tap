cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.256"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.256/agentshield_0.2.256_darwin_amd64.tar.gz"
      sha256 "0767282d4ae8e6c5a9b3f5d54f8c1431a6bd735dbe7e328b25762af90fbbcf50"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.256/agentshield_0.2.256_darwin_arm64.tar.gz"
      sha256 "2f18dab772236e508f17f342cfdbb14eb801a20bcbe0b220d2ef214a0732b30e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.256/agentshield_0.2.256_linux_amd64.tar.gz"
      sha256 "2f07670ae792949376540ba202a7bf8f9408cfa598eaa4fcee27a9a491dbdfc4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.256/agentshield_0.2.256_linux_arm64.tar.gz"
      sha256 "da0555f4c38930517ccd8916f28de122d87a089f89cd0519b5020356ba49b55f"
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
