cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1310"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1310/agentshield_0.2.1310_darwin_amd64.tar.gz"
      sha256 "f54aca649f50ccfda142c7aa01128429ac15947b028b47145ce3844fbdd638a5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1310/agentshield_0.2.1310_darwin_arm64.tar.gz"
      sha256 "ce6ceaec6d4e337fe03237744d367e4c57d6ef6e2c53a6d1d406ba41b1c44acb"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1310/agentshield_0.2.1310_linux_amd64.tar.gz"
      sha256 "e026324184b5d368e2f497da43848fe8d471d053ba60484d0860c6d74e146680"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1310/agentshield_0.2.1310_linux_arm64.tar.gz"
      sha256 "e092fd584a611a05a1236dfbca5cfdac4f7afba6104cc11307d1e5910562ad2b"
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
