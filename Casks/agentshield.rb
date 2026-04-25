cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.725"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.725/agentshield_0.2.725_darwin_amd64.tar.gz"
      sha256 "236c0db08b760e2298788c8b5519e73c3c547a23df76cd0da81f12023b71467e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.725/agentshield_0.2.725_darwin_arm64.tar.gz"
      sha256 "b40301e3faf4b75a06bc6a4a7fa64d1c9ab4b7d5ea45947bfc3f56ee05232ebc"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.725/agentshield_0.2.725_linux_amd64.tar.gz"
      sha256 "520caf62019108084aad30c0c0c5712ec5bd6795ea03f8d04041769ccccb2146"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.725/agentshield_0.2.725_linux_arm64.tar.gz"
      sha256 "f6f768336485173883f35aa2399aff5f96ef84f6a18b3d6d663b4ee9e541906f"
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
