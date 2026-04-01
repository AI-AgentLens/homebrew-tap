cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.282"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.282/agentshield_0.2.282_darwin_amd64.tar.gz"
      sha256 "430642166503ae6dbe09226abdc0125da6a8ee8ea81bb133517346c84f9d8ef7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.282/agentshield_0.2.282_darwin_arm64.tar.gz"
      sha256 "a8e7c0a616e8989ad4b70510bea359ff851a320a1c7cb319ab1fd15b3c07e6ce"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.282/agentshield_0.2.282_linux_amd64.tar.gz"
      sha256 "74e97bfdebd2e4b01e999f09c1d8242a0193e2f793774fe0816e6a763ab75967"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.282/agentshield_0.2.282_linux_arm64.tar.gz"
      sha256 "67380d1ee2d4bdfdca63f32b2a5bf0428597da1024276a72aa6b60bb52240855"
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
