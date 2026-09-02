cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2026"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2026/agentshield_0.2.2026_darwin_amd64.tar.gz"
      sha256 "f9a9d61ea51af19d19a00e3d036afdd0adb428fc46e6edbe0b71a470284e9558"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2026/agentshield_0.2.2026_darwin_arm64.tar.gz"
      sha256 "4537a10534ce9ea4e55136a57ee23dc7cd438c0501ef1416e6c22aaa4278a2ac"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2026/agentshield_0.2.2026_linux_amd64.tar.gz"
      sha256 "3556ab06476e6204c88fb7dd543dc55a5c573f208a1ffb3b0d9f6d8b87c4bff0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2026/agentshield_0.2.2026_linux_arm64.tar.gz"
      sha256 "911938de9ac58b30dfdc238686a55603e508b6cfb3d3dbb6d29ae11d1aca1a14"
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
