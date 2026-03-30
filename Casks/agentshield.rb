cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.251"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.251/agentshield_0.2.251_darwin_amd64.tar.gz"
      sha256 "ce08fc1d3e694a8e87590021fb528f4dda020a49fc2961fdd8943a441f71f76c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.251/agentshield_0.2.251_darwin_arm64.tar.gz"
      sha256 "874010d3f10e2112500022084921a1bd219439fb5fe8b24b74d4f9493b98008b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.251/agentshield_0.2.251_linux_amd64.tar.gz"
      sha256 "38f0f38465427a69e3971102b4c6d2af148aababff326badc315d953c5b34ce0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.251/agentshield_0.2.251_linux_arm64.tar.gz"
      sha256 "e15ff957ff72a31328d5918accff7300815f9dddae2ff804d6a0fc7d5e698b96"
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
