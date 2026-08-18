cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1899"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1899/agentshield_0.2.1899_darwin_amd64.tar.gz"
      sha256 "1abe9798ad9ce78b0958119d2b48a8109ac15d64f0e7e572d9ff019c6c641309"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1899/agentshield_0.2.1899_darwin_arm64.tar.gz"
      sha256 "a38709e314dccd6d11e4ea6b5ec0d89ad73cc79abb9351d031304176b195528e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1899/agentshield_0.2.1899_linux_amd64.tar.gz"
      sha256 "5e2670f0c25c995b28e47a21d54be052ea4e46fb797ea404faac944deb156b92"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1899/agentshield_0.2.1899_linux_arm64.tar.gz"
      sha256 "813bf6cbf32d19ddb4e174680f6b922f014b3f862ac49cfccbbcebe65b6dd632"
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
