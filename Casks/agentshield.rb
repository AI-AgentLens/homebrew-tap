cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2242"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2242/agentshield_0.2.2242_darwin_amd64.tar.gz"
      sha256 "6fd8417306476149880f62013b62218161eb97c2c88d63d4e8397490a2db6879"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2242/agentshield_0.2.2242_darwin_arm64.tar.gz"
      sha256 "7149bb58414ab590b78612a6f6550948d2efcaffc8540a4030c3267bda696947"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2242/agentshield_0.2.2242_linux_amd64.tar.gz"
      sha256 "45f4dcc2589c0d0d9e2ea6b9557a83e77810f1e8bcfa016af835a7df126616ce"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2242/agentshield_0.2.2242_linux_arm64.tar.gz"
      sha256 "9199eda3c764d4000d071a62c16146a94565d17b739bb9e2acc89c28f1aa13f2"
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
