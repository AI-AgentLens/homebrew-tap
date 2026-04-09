cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.511"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.511/agentshield_0.2.511_darwin_amd64.tar.gz"
      sha256 "8352bb09f72a110b587a09c808d363d768a7cef9eab0db328c80c084774e2fb3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.511/agentshield_0.2.511_darwin_arm64.tar.gz"
      sha256 "8f86a5ee6bf8837e84b65dac920c55f66e4b753e62b4b71fa7a222fb469ad320"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.511/agentshield_0.2.511_linux_amd64.tar.gz"
      sha256 "684bb9735720ce34157753939543f98156be94a80dba1ebdacbc1bd2c3779f07"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.511/agentshield_0.2.511_linux_arm64.tar.gz"
      sha256 "380ae5e8ee35d8db8e7bb18f5f26a4767187f1ed9707ba0b3e1e85eba8c29c2e"
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
