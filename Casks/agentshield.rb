cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1166"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1166/agentshield_0.2.1166_darwin_amd64.tar.gz"
      sha256 "f64cd1b178b9aee85dadef15bdcaa5bd1c43d39b7e52b3358cd6915d48d7bff1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1166/agentshield_0.2.1166_darwin_arm64.tar.gz"
      sha256 "467e3161850e619cfad9ca708ac07eea514bcc8fdb02ce3ac5f7ba65b319cf58"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1166/agentshield_0.2.1166_linux_amd64.tar.gz"
      sha256 "48401f6e73a46b92abd2c68197a8418f9e4449d4e085173ac78cfc0c081e8631"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1166/agentshield_0.2.1166_linux_arm64.tar.gz"
      sha256 "91e2d356c3a33b103771a7fcc318f4bd62064e8ce72e9933e86064f63c7b44e0"
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
