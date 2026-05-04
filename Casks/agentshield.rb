cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.880"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.880/agentshield_0.2.880_darwin_amd64.tar.gz"
      sha256 "c12ebc343a201fbd426f779a767cf24f6996fe76b773ac36afa2b88aacf41836"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.880/agentshield_0.2.880_darwin_arm64.tar.gz"
      sha256 "bc5f1c7ad1906187ae7cd2fec456161a528e826f188948f1926fd4d365351ed2"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.880/agentshield_0.2.880_linux_amd64.tar.gz"
      sha256 "d5bcb4b74201ac87ad2cb088c5646b81299892c1bae27e9b84f8728a0e184fb4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.880/agentshield_0.2.880_linux_arm64.tar.gz"
      sha256 "038caa41e455dfad49ad0ee987c3f95703be91a4ccea661388d807f76f19b464"
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
