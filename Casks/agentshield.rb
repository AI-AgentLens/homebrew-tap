cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1174"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1174/agentshield_0.2.1174_darwin_amd64.tar.gz"
      sha256 "f1ee8ba4490d4d592b981a15ba082824ab4e6a657147f42fadd6c909f6fae683"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1174/agentshield_0.2.1174_darwin_arm64.tar.gz"
      sha256 "c22486769a7678f65f7f64ca6e3417a5b87f8df428c0a19f91ecb0ff517f4743"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1174/agentshield_0.2.1174_linux_amd64.tar.gz"
      sha256 "7f19f30b0a5b262504f33afca48934eb8e92d5df15a07c0a2a85daab9b6f1da8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1174/agentshield_0.2.1174_linux_arm64.tar.gz"
      sha256 "78ba177fde50429a1d47c29ac0bf86c9971af0e607cfc869bad20bf414f567a6"
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
