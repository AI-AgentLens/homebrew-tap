cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1164"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1164/agentshield_0.2.1164_darwin_amd64.tar.gz"
      sha256 "78e93ac1e034617b1affd3bcf234dd10c78c24361ecd1d58190bc39bfdc7ce8f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1164/agentshield_0.2.1164_darwin_arm64.tar.gz"
      sha256 "8b18c1efa7015d0f5335d2307c72a760bc9b011d071e436d7005f8ec9c8bc15a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1164/agentshield_0.2.1164_linux_amd64.tar.gz"
      sha256 "4b65b4d5f0e718ead7f841e1b66e0482086519315a8eae2797bb90733b7536fb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1164/agentshield_0.2.1164_linux_arm64.tar.gz"
      sha256 "545dae1a21187a0b1f19c45d75403def2dd7c8c2743e021b8bc74e9f875750e6"
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
